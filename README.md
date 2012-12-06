[![Build Status](https://travis-ci.org/stephenrjohnson/rsaenc.png)](https://travis-ci.org/stephenrjohnson/rsaenc)

RSA ENC File Type / Functions / Face
====================================

Description
-----------
The respository contains three distinct items.
1.    Face
2.    Type
3.    Functions

Usage Face
----------
### Encypting a file

By default if you do not pass in a key file then the local public key will be used

	$ puppet rsaenc encrypt --input=/root/test --output=/etc/puppet/modules/secret/templates/enc.data

You can specify a key file as follows

	$ puppet rsaenc encrypt --input=/root/test --output=/etc/puppet/modules/secret/templates/enc.data --key=/var/lib/puppet/ssl/public_keys/host.pem

### Decrypting a file

By default if you do not pass in a key file then the local private key will be used

	$ puppet rsaenc decrypt --input=/etc/puppet/modules/secret/templates/enc.data --output=/root/file

You can specify a key file as follows

	$ puppet rsaenc decrypt --input=/etc/puppet/modules/secret/templates/enc.data --output=/root/file --key=/var/lib/puppet/ssl/private_keys/host.pem

Usage Provider
--------------

Once you have created an ecrypted file for a host you can use the provider on that host to decrypt it.

	enc_file { 'supersecretfile':
	      path => '/etc/secrets',
	      contents => template('secret/enc.data'),
	    }
	file { 'supersecretfile':
	      path => '/etc/secrets',
	      ensure => file,
	      owner => root,
	      group => root,
	      mode => 0400,
	    }

Please note this will only work on the host that you have encrypted the file for using the hosts public key.

Usage Functions
---------------

If you want to encrypt a file for multiple hosts and dont care able to be decrypted on the puppet master and it being in the catalog.

First encrypt the file on the puppet master.

	$ puppet rsaenc encrypt --input=/root/test --output=/etc/puppet/modules/secret/templates/enc.data

	file { 'supersecretfile':
	      path => '/etc/secrets',
	      content => decrypt_rsa(template('secret/enc.data')),
	      ensure => file,
	      owner => root,
	      group => root,
	      mode => 0400,
	}

You can also add a filter if you wish to be paranoid and limit it to cerntain hosts

	$ puppet rsaenc encrypt --input=/root/test --output=/etc/puppet/modules/secret/templates/enc.data --filter=host1.example.com,host2.example.com

	file { 'supersecretfile':
	      path => '/etc/secrets',
	      content => decrypt_rsa(template('secret/enc.data'),$fqdn),
	      ensure => file,
	      owner => root,
	      group => root,
	      mode => 0400,
	}

If the second argument to the decrypt function isn't in the filter the catalog will fail to compile. You could also encypt the data in the catalog by doing.

	enc_file { 'supersecretfile':
	    path => '/etc/secrets',
	    content => encrypt_rsa(decrypt_rsa(template('secret/enc.data'),$fqdn),"${settings::publickeydir}/${clientcert}.pem")
	 }
	file { 'supersecretfile':
	      path => '/etc/secrets',
	      ensure => file,
	      owner => root,
	      group => root,
	      mode => 0400,
	}


You can also encrypt simple strings

	enc_file { 'supersecretfile':
	    path => '/etc/secrets',
	    content => encrypt_rsa("simplestring","${settings::publickeydir}/${clientcert}.pem")
	 }
	file { 'supersecretfile':
	      path => '/etc/secrets',
	      ensure => file,
	      owner => root,
	      group => root,
	      mode => 0400,
	}

This is very beta so be careful as the encrypted file formate may change. 