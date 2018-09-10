Red Hat SSO + Azure AD lab
=========

This code help's you boot an enviroment to test RH SSO with Azure AD. It builds the following components:
  - Active Directory VM in azure to create your local account
  - Linux VM with RH SSO and Apache installed
  - Uses let's encrypt to create certificates.

Requirements
------------

  - Azure account
  - Domain name with name server pointing at azure name servers.
  - Red Hat subscription

Important Variables
--------------

Please look inside the `inventory/group_vars/main.yml` for the list of variables.

Dependencies
------------

  - [ansible-role-active-directory](https://github.com/sperreault/ansible-role-active-directory)
  - [ansible-role-redhat-subscription](https://github.com/openstack/ansible-role-redhat-subscription) or use [this fork](https://github.com/sperreault/ansible-role-redhat-subscription) to use an activation key instead of a username and password.
  - [ansible-role-rhsso](https://github.com/sperreault/ansible-role-rhsso)

How to Use
----------------

To use this playbooks and dependencies you have 2 ways: 
  - Have your python and ansible environment setup with Python 2.6.3+ and the azure modules installed 
  - Use virtualenv to create the proper environment for you.

In both cases you need to setup the following environment variable:
  - AZURE_CLIENT_ID
  - AZURE_TENANT
  - AZURE_SUBSCRIPTION_ID
  - AZURE_SECRET
  - PYTHON_EXEC

If you are to use your own enviroment execute the following:
```
 make requirements
 ansible-playbook provision.yml
```

If you plan on using virtualenv (recommended):
```
 make venv
 make requirements
 source venv/bin/activate
 export PYTHON_EXEC=`which python`
 ansible-playbook provision.yml
```

License
-------

BSD
