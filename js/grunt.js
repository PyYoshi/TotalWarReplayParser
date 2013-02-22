/*global module:false*/
module.exports = function (grunt) {
    // Project configuration.
    grunt.initConfig({
        pkg: '<json:package.json>',
        meta: {
            banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
                '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
                '<%= pkg.homepage ? "* " + pkg.homepage + "\n" : "" %>' +
                '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
                ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */'
        },
        coffee: {
            dist: {
                files: {
                    'dist/ReplayParser.js': [
                        'src/env.coffee',
                        'src/utils.coffee',
                        'src/errors.coffee',
                        'src/models.coffee',
                        'src/reader.coffee',
                        'src/codecs/core.coffee',
                        'src/codecs/abcd.coffee',
                        'src/codecs/abce.coffee',
                        'src/codecs/abcf.coffee',
                        'src/codecs/abca.coffee',
                        'src/replay_parser.coffee'
                    ],
                    'dist/tests/main.js':[
                        'tests/main.coffee'
                    ]
                },
                options: {
                    bare: true
                }
            },
            dev: {
                files: {
                    'dist/ReplayParser.js': [
                        'src/envd.coffee',
                        'src/utils.coffee',
                        'src/errors.coffee',
                        'src/models.coffee',
                        'src/reader.coffee',
                        'src/codecs/core.coffee',
                        'src/codecs/abcd.coffee',
                        'src/codecs/abce.coffee',
                        'src/codecs/abcf.coffee',
                        'src/codecs/abca.coffee',
                        'src/replay_parser.coffee'
                    ],
                    'dist/tests/main.js':[
                        'tests/main.coffee'
                    ]
                },
                options: {
                    bare: true
                }
            }

        },
        copy: {
            dist: {
                files: [
                    {
                        src: ['DataStream.js', 'tests/example.html'],
                        dest: 'dist/',
                        options:{}
                    }
                ]
            }
        },
        concat:{

        },
        min: {
            dist:{
                src: ['dist/ReplayParser.js'],
                dest: 'dist/ReplayParser.min.js'
            },
            dataStream:{
                src: ['dist/DataStream.js'],
                dest:'dist/DataStream.min.js'
            }
        },

        clean: {
            dist: {
                src: ['dist']
            }
        },
        watch: {
            dist: {
                files: [
                    'src/*.coffee',
                    'src/*/*.coffee',
                    'tests/*.html',
                    'DataStream.js'
                ],
                tasks: 'coffee copy min'
            },
            dev: {
                files: [
                    'src/*.coffee',
                    'src/*/*.coffee',
                    'tests/*.html',
                    'DataStream.js'
                ],
                tasks: 'coffee:dev copy'
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib');
    // Default task.
    grunt.registerTask('default', 'clean coffee min');

};