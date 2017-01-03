#!/bin/bash
set -eo pipefail

# script to install Ansible and dependencies.

### functions

install_packages() {
  # python dependency packages
  if [[ -f /etc/debian_version ]] || [[ -f /etc/lsb_release ]]; then
    PKG_MANAGER="apt-get"
    PKG_MANAGER_OPTIONS="-y --force-yes --no-install-recommends"
    PACKAGES="python-dev python-setuptools python-pip gcc libssl-dev libffi-dev apt-transport-https"
    echo "* running apt-get update"
    $SUDO_CMD apt-get update
    echo "  done."
    echo
  elif [[ -f /etc/redhat-release ]] || [[ -f /etc/fedora-release ]] || [[ -f /etc/system-release ]]; then
    PKG_MANAGER="yum"
    PKG_MANAGER_OPTIONS="-y"
    PACKAGES="python-devel python-setuptools python-pip gcc openssl-devel libffi libffi-devel"
  fi

  echo "* installing packages"
  $SUDO_CMD $PKG_MANAGER install $PACKAGES $PKG_MANAGER_OPTIONS
  echo "  done."
  echo
}

install_pip() {
  # install pip
  if ! which pip 2>1 > /dev/null; then
    echo "* installing pip via easy_install"
    $SUDO_CMD easy_install pip
    if ! which pip; then
      echo "* failed to install pip using easy_install."
      exit 1
    fi
  else
    echo "* pip is already installed"
  fi
  echo "  done."
  echo
}

install_virtualenv() {
  # install virtualenv
  if ! which virtualenv 2>1 > /dev/null; then
    echo "* installing virtualenv via easy_install"
    $SUDO_CMD easy_install virtualenv
    if ! which virtualenv; then
      echo "* failed to install virtualenv using easy_install."
      exit 1
    fi
  else
    echo "* virtualenv is already installed"
  fi
  echo "  done."
  echo
}

setup_venv() {
  # setup venv
  if ! ls -l $VENV_ACTIVATE_CMD 2>1 > /dev/null; then
    if virtualenv --python=python2 --system-site-packages "$ANSIBLE_VENV_DIR"; then
      echo "* created python virtual environment for ansible at location $ANSIBLE_VENV_DIR"
    else
      echo "* failed to create python virtual environment for ansible at location $ANSIBLE_VENV_DIR"
      exit 1
    fi
  else
    echo "* python virtual environment already exists at location $ANSIBLE_VENV_DIR"
  fi
  source $VENV_ACTIVATE_CMD
  echo "  done."
  echo
}

update_pip() {
  # install/upgrade pip
  if pip install --upgrade pip; then
    echo "* upgraded pip"
  else
    echo "* failed to upgrade pip"
    exit 1
  fi
  echo "  done."
  echo
}

install_setuptools() {
  # install/upgrade setuptools
  if pip install --upgrade setuptools; then
    echo "* upgraded setuptools"
  else
    echo "* failed to upgrade setuptools"
    exit 1
  fi
  echo "  done."
  echo
}

extra_pip_packages() {
  if pip install pyopenssl pyasn1 ndg-httpsclient; then
    echo "* installed pip packages pyopenssl pyasn1 ndg-httpsclient"
  else
    echo "* failed to install pip packages pyopenssl pyasn1 ndg-httpsclient"
  fi
  echo "  done."
  echo
}

install_jinja2() {
  # install/upgrade jinja2
  if pip install --upgrade jinja2; then
    echo "* upgraded jinja2"
  else
    echo "* failed to upgrade jinja2"
    exit 1
  fi
  echo "  done."
  echo
}

install_ansible() {
  # install ansible
  VERSION=$1
  if pip install --upgrade ansible==${VERSION}; then
    echo "* upgraded ansible version $VERSION"
  else
    echo "* failed to upgrade ansible $VERSION"
    exit 1
  fi
  echo "  done."
  echo
}

#### Main

SUDO_CMD=
ANSIBLE_VERSION=${ANSIBLE_VERSION-2.2.0.0}
ANSIBLE_VENV_DIR=${ANSIBLE_VENV_DIR-/etc/ansible/venv}
VENV_ACTIVATE_CMD="$ANSIBLE_VENV_DIR/bin/activate"
ANSIBLE_CMD="$ANSIBLE_VENV_DIR/bin/ansible"

echo "* vars:"
echo "  ANSIBLE_VERSION=$ANSIBLE_VERSION"
echo "  ANSIBLE_VENV_DIR=$ANSIBLE_VENV_DIR"
echo "  VENV_ACTIVATE_CMD=$VENV_ACTIVATE_CMD"
echo "  ANSIBLE_CMD=$ANSIBLE_CMD"
echo "  SUDO_CMD=$SUDO_CMD"
echo
echo "* creating directory /etc/ansible"
mkdir -p /etc/ansible
echo "  done."
echo

install_packages
install_pip
install_virtualenv
setup_venv
update_pip
install_setuptools
extra_pip_packages
install_jinja2
install_ansible $ANSIBLE_VERSION

echo "* installed ansible v$ANSIBLE_VERSION successfully"
echo "  done."
echo
echo "# to activate ansible virtual env, run the following command:"
echo "    source $VENV_ACTIVATE_CMD"
echo
exit 0
