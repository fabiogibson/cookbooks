class buildserver {

    class { 'apt':
        update => {
            frequency => 'always',
        },
    }

    package { ['git']:
    	ensure => "installed",
    }

    class { 'jenkins':
        config_hash => {
            'JAVA_ARGS' => { 'value' => '-Xmx256m' }
        },
    }

    $plugins = []

    jenkins::plugin { $plugins: }

    class { 'docker':
        docker_users    => ['fgibson'],
 	    tcp_bind        => ['tcp://0.0.0.0:2375'],
        socket_bind     => 'unix:///var/run/docker.sock',
    }
}
