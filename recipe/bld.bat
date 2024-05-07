@echo on
setlocal enabledelayedexpansion

pip install . -vv --no-build-isolation --config-settings=setup-args=%MESON_ARGS_REDUCED%
