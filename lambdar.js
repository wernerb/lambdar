'use strict';

const fs = require('fs');
const spawnSync = require('child_process').spawnSync;

/** The version of R */
const version = '3.3.2';

function spawn(command, args) {
    const output = spawnSync(command, args, {
        env: {
            HOME: process.cwd(),
            LD_LIBRARY_PATH: '/tmp/r/${version}/lib64/R/lib'
        }
    });
    if (output.error != null) {
        console.log(output);
        return output.error.toString();
    }
    const s = output.stdout.toString() + output.stderr.toString();
    console.log(s);
    return s;
}

function install_r() {
    if (fs.existsSync('/tmp/r'))
        return;
    spawn('tar', ['xf', `/var/task/r-${version}.tar.gz`, '-C', '/tmp']);
}

function eval_rscript(file) {
  process.env.HOME = '/tmp/r';
  process.chdir('/tmp/r');
  return spawn(`/tmp/r/${version}/bin/Rscript`, [file])
}

/**
 * Transfer bottles from CircleCI to BinTray and GitHub
 */
exports.handler = (event, context, callback) => {
    console.log('Received event:', JSON.stringify(event, null, 2));

    const done = (err, res) => callback(null, {
        statusCode: err ? '400' : '200',
        body: err ? err.message : res,
        headers: {
            'Content-Type': 'text/plain',
        },
    });

    switch (event.httpMethod) {
        case 'GET':
            install_r();
            done(null, eval_rscript(__dirname + '/script.R'));
            break;
        case 'POST':
            //run specific R with parameters
            install_r();
            done(null, eval_rscript(__dirname + '/script.R'));
            break;
        default:
            done(new Error(`lambdar: Unsupported HTTP method "${event.httpMethod}"`));
    }
};
