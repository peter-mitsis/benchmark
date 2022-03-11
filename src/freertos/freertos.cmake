# Recall that this fragment is included by "../../CMakeLists.txt".
# Consequently, all relative paths are relative to "../..".

if (NOT MCUX_SDK_PATH)
    message(FATAL_ERROR "Please, inform MCUXpresso SDK path via MCUX_SDK_PATH")
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DFREERTOS")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DCPU_MK64FN1M0VLL12")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DSERIAL_PORT_TYPE_UART=1")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mcpu=cortex-m4")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mfpu=fpv4-sp-d16")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mthumb")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mfloat-abi=hard")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffreestanding")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__STARTUP_CLEAR_BSS")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DSYS_CLOCK_HW_CYCLES_PER_SEC=120000000")

set(CONFIG_ARM ON)
set(CONFIG_CPU_CORTEX_M ON)

set(CMAKE_TOOLCHAIN_FILE ${MCUX_SDK_PATH}/tools/cmake_toolchain_files/armgcc.cmake)

enable_language(ASM)

include_directories(src/freertos)
include_directories(${MCUX_SDK_PATH}/CMSIS/Core/Include)
include_directories(${MCUX_SDK_PATH}/components/serial_manager)
include_directories(${MCUX_SDK_PATH}/components/uart)
include_directories(${MCUX_SDK_PATH}/devices/MK64F12)
include_directories(${MCUX_SDK_PATH}/devices/MK64F12/drivers)
include_directories(${MCUX_SDK_PATH}/devices/MK64F12/utilities/debug_console)
include_directories(${MCUX_SDK_PATH}/devices/MK64F12/utilities/str)
include_directories(${MCUX_SDK_PATH}/rtos/freertos/freertos_kernel/include)
include_directories(${MCUX_SDK_PATH}/rtos/freertos/freertos_kernel/portable/GCC/ARM_CM4F)

add_executable(app src/freertos/bench_porting_layer_freertos.c)

target_sources(app PRIVATE ${MCUX_SDK_PATH}/components/serial_manager/fsl_component_serial_manager.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/components/serial_manager/fsl_component_serial_port_uart.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/components/uart/fsl_adapter_uart.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/devices/MK64F12/drivers/fsl_clock.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/devices/MK64F12/drivers/fsl_smc.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/devices/MK64F12/drivers/fsl_uart.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/devices/MK64F12/gcc/startup_MK64F12.S)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/devices/MK64F12/system_MK64F12.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/devices/MK64F12/utilities/debug_console/fsl_debug_console.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/devices/MK64F12/utilities/debug_console/fsl_debug_console.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/devices/MK64F12/utilities/fsl_sbrk.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/devices/MK64F12/utilities/str/fsl_str.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/rtos/freertos/freertos_kernel/list.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/rtos/freertos/freertos_kernel/portable/GCC/ARM_CM4F/port.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/rtos/freertos/freertos_kernel/portable/MemMang/heap_4.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/rtos/freertos/freertos_kernel/queue.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/rtos/freertos/freertos_kernel/stream_buffer.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/rtos/freertos/freertos_kernel/tasks.c)
target_sources(app PRIVATE ${MCUX_SDK_PATH}/rtos/freertos/freertos_kernel/timers.c)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --specs=nano.specs")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --specs=nosys.specs")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -T${CMAKE_CURRENT_SOURCE_DIR}/src/freertos/MK64FN1M0xxx12_flash.ld")

target_link_libraries(app PRIVATE -Wl,--start-group)
target_link_libraries(app PRIVATE c)
target_link_libraries(app PRIVATE gcc)
target_link_libraries(app PRIVATE nosys)
target_link_libraries(app PRIVATE -Wl,--end-group)

set(EXEC_NAME freertos.elf)
set_target_properties(app PROPERTIES OUTPUT_NAME ${EXEC_NAME})

add_custom_target(flash USES_TERMINAL DEPENDS app COMMAND pyocd load --target k64f ${EXEC_NAME})
add_custom_target(debugserver USES_TERMINAL DEPENDS app COMMAND pyocd gdbserver --target k64f)
