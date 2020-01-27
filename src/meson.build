cpp_headers = []

cpp_sources = [
          'ffi_c.cpp',
          ]

headers = ['../include/gdk.h', ]

sources = cpp_headers + cpp_sources + headers

if clang_format.found()
    custom_target('clang-format', input : sources, output : 'clang-format', command : [clang_format, '-i', '@INPUT@'])
endif

fix_compilation_db = clang_tidy.found() or pvs_studio_analyzer.found() or infer.found()
if fix_compilation_db
    fix_compile_commands = custom_target('fix-compile-commands', output : 'compile_commands.json', capture : true,
                                          command : ['sed', '-e', 's/-MD//g', '-e', 's/-pipe//g', '-e', 's!src!./src!g', 'compile_commands.json'])
endif

if clang_tidy.found()
    custom_target('clang-tidy', input : cpp_sources, output : 'clang-tidy', command : [clang_tidy, '-p=' + join_paths(meson.build_root(), 'src'), '@INPUT@'],
                   depends : fix_compile_commands)
endif

if pvs_studio_analyzer.found()
    custom_target('pvs-studio-analyzer', output : 'pvs-studio-analyzer',
                   command : [join_paths(meson.source_root(), 'tools', 'run_pvs_studio_analyzer.sh'), meson.build_root()], depends : fix_compile_commands)
endif

if infer.found()
    custom_target('infer', output : 'infer',
                   command : [infer, '--keep-going', '-a', 'checkers', '--compilation-database', 'compile_commands.json'], depends : fix_compile_commands)
endif

commit_id = vcs_tag('commit_id', input : 'version.h.in', output : 'version.h',
                    command : ['git', '-C', meson.source_root(), 'rev-parse', 'HEAD'])
sources += commit_id

dependencies = subproject_deps + library_deps

local_link_args = []
link_whole = []
if build_jni
    message('Building JNI bindings...')
    subdir('swig_java')
    link_whole += [libswig_java]
else
    message('Disabled JNI bindings')
endif

if build_swig_python
    subdir('swig_python')
    link_whole += [libswig_python]
else
    message('Disabled Python bindings')
endif

install_headers(
    headers,
    subdir : 'gdk')

install_data(
    '../include/module.modulemap',
    install_dir : 'include/gdk')

install_data(
    join_paths(meson.source_root(), 'src', 'swift', 'GreenAddress', 'Sources', 'GreenAddress', 'GreenAddress.swift'))

if cross_android_build or cross_iphone_build
    libga_installdir = join_paths('lib', meson.get_cross_property('ndk_lib_dir'))
else
    libga_installdir = 'lib'
endif

libga = both_libraries('greenaddress',
                        sources,
                        include_directories : incdir,
                        link_whole : link_whole,
                        link_args : local_link_args,
                        dependencies : dependencies,
                        install : true,
                        install_dir : libga_installdir)

if not cross_android_build
    archiver = custom_target('archiver',
                             output : 'libgreenaddress_full.a',
                             command : [join_paths(meson.source_root(), 'tools', 'archiver.sh'), meson.build_root(), ar],
                             build_by_default : true,
                             install : true,
                             install_dir : libga_installdir,
                             depends : libga)
endif

if objcopy.found() and not is_darwin
    # Extract the debug symbols from the un-stripped version in build-**
    custom_target('external debug symbols',
                  output : 'libgreenaddress.syms',
                  command : [objcopy, '--only-keep-debug', libga.full_path(), join_paths(meson.build_root(), 'src', 'libgreenaddress.syms')],
                  build_by_default : true,
                  install : true,
                  install_dir : libga_installdir,
                  depends : libga)
endif

# tests
subdirs = ['swift']
foreach n : subdirs
    subdir(n)
endforeach
