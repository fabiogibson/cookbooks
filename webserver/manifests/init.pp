class webserver($web_app) {

	group { 'httpusers' :
	    ensure => 'present',
	    gid    => '500',
	}

	user { $web_app :
	    ensure           => 'present',
	    home             => "/home/${$web_app}",
	    comment          => 'Web Application User',
	    shell            => '/bin/bash',
	    uid              => '501',
	    groups           => ['httpusers'],
	    require          => Group['httpusers']
	}

	user { 'jenkins' :
	    ensure           => 'present',
	    home             => '/home/jenkins',
	    comment          => 'Jenkins CI User',
	    shell            => '/bin/bash',
	    uid              => '502',
	    password         => '$1$5wdlPqiV$FFmYZeutFyA2RtDQeiQOl0' #qazwsx, 
	    managehome 	     => true,
	    groups	     => []	
	}

	file { ['/home/jenkins/.virtualenvs'] : 
	    ensure 	     => 'directory',
	    owner	     => 'jenkins',
	}

	class { 'python' :
	    pip        => 'present',
	    dev        => 'present',
	    virtualenv => 'present',
	    gunicorn   => 'absent',
	}

	python::virtualenv { 'venv' :
	    version      => 'system',
	    distribute   => false,
	    venv_dir     => "/home/jenkins/.virtualenvs/${$web_app}",
	    owner        => 'jenkins',
	    timeout      => 0,
	} 

	file { "/etc/init/${$web_app}.conf" :
            content => template('webserver/gunicorn.conf.erb'),
            ensure => present
	} 

	package { ['nginx'] :
	    ensure  => "installed"
	} ->
	file { "/etc/nginx/sites-enabled/default":
	    ensure => 'absent',
	    purge  => true
	} ->
	file { "/etc/nginx/sites-available/${$web_app}" :
            content => template('webserver/site.erb'),
            ensure  => present
	} ->
	file { "/etc/nginx/sites-enabled/${$web_app}":
	    ensure => 'link',
            target => "/etc/nginx/sites-available/${$web_app}",
	} ~>
	service { 'nginx' :
	    ensure => 'running'
	}

	sudoers::allowed_command{ "jenkins":
	    command          => "/usr/sbin/service nginx restart, /usr/sbin/service ${$web_app} restart",
	    user             => "jenkins",
	    require_password => false,
	    comment          => "Allows user jenkins to restart both nginx and app gunicorn services."
	}
}
