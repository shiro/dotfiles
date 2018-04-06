@echo off

set home=%userprofile%

set fileList=("%home%\.PhpStorm*" ^
              "%home%\.IntelliJIdea*" ^
              "%home%\.Rider*" ^
              "%home%\.GoLand*" ^
              "%home%\.DataGrip*" ^
              "%home%\.CLion*" ^
             )

echo searching for IDEA applications in %home%
echo =========================================

for /d %%F in %fileList% do (
  echo [LINK] %%F

  for %%x in (keymaps colors codestyles) do (
    rd /s /q "%%F\config\%%x" > NUL 2>&1
    mklink /J "%%F\config\%%x" ".\\idea\\%%x" > NUL
  )
)

echo =========================================
echo linking finished
