'use strict';

module.exports = function(grunt) {
    grunt.initConfig({
        coffee: {
            compileBare: {
                options: {
                    bare: true
                },
                files: {
                    'dist/ReplayParser.js': [
                        'DataStream.coffee',
                        'src/env.coffee',
                        'src/utils.coffee',
                        'src/errors.coffee',
                        'src/models.coffee',
                        'src/reader.coffee',
                        'src/codecs/core.coffee',
                        'src/codecs/abce.coffee',
                        'src/codecs/abcd.coffee',
                        'src/codecs/abcf.coffee',
                        'src/codecs/abca.coffee',
                        'src/replay_parser.coffee'
                    ],
                    'dist/tests/main.js':[
                        'tests/main.coffee'
                    ]
                }
            },
            compileBareMaps: {
                options: {
                    sourceMap: true,
                    bare: true
                },
                files: {
                    'dist/ReplayParser.js': [
                        'DataStream.coffee',
                        'src/envd.coffee',
                        'src/utils.coffee',
                        'src/errors.coffee',
                        'src/models.coffee',
                        'src/reader.coffee',
                        'src/codecs/core.coffee',
                        'src/codecs/abce.coffee',
                        'src/codecs/abcd.coffee',
                        'src/codecs/abcf.coffee',
                        'src/codecs/abca.coffee',
                        'src/replay_parser.coffee'
                    ],
                    'dist/tests/main.js':[
                        'tests/main.coffee'
                    ]
                }
            }
        },
        uglify: {
            product: {
                files: {
                    'dist/ReplayParser.min.js': ['dist/ReplayParser.js']
                }
            }
        },
        watch: {
            options: {
                dateFormat: function(time) {
                    grunt.log.writeln('The watch finished in ' + time + 'ms at' + (new Date()).toString());
                    grunt.log.writeln('Waiting for more changes...');
                }
            },
            script:{
                files: [
                    'src/*.coffee',
                    'src/*/*.coffee',
                    'tests/*.html',
                    'DataStream.coffee'
                ],
                tasks:['coffee:compileBareMaps'],
                options:{
                    spawn:true,
                    livereload: true
                }
            }
        }
    });

    // $ grunt coffee
    grunt.loadNpmTasks('grunt-contrib-coffee');

    // $ grunt watch
    grunt.loadNpmTasks('grunt-contrib-watch');

    // $ grunt uglify
    grunt.loadNpmTasks('grunt-contrib-uglify');

    // $ grunt
    grunt.registerTask('default', ['coffee:compileBare', 'uglify:product']);
};