file( GLOB APP_SOURCES "*.cpp" )

foreach( src ${APP_SOURCES} )
  get_filename_component(exec_name ${src} NAME_WE)
  add_executable( ${exec_name} ${src} )
endforeach( src ${APP_SOURCES} )

