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

    $plugins = [
        'credentials',
        'ssh-credentials',
        'git-client',
        'mailer',
        'promoted-builds',
        'matrix-project',
        'token-macro',
        'scm-api',
        'ws-cleanup',
        'parameterized-trigger',
        'copyartifact',
        'git',
        'publish-over-ssh',
        'backup'
    ]

    jenkins::plugin { $plugins: }
}