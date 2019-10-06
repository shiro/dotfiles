@echo off

set home=%userprofile%
set dotIdeaDir=%~dp0..\idea

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

  rem link folders
  for %%x in (keymaps colors codestyles) do (
    rd /s /q "%%F\config\%%x" > NUL 2>&1
    mklink /J "%%F\config\%%x" "%dotIdeaDir%\%%x" > NUL
  )

  rem link options
  for /f %%i in ('dir /b "%dotIdeaDir%\options\*"') do (
    rm %%F\config\options\%%i > NUL 2>&1
    mklink "%%F\config\options\%%i" "%dotIdeaDir%\options\%%i" > NUL
  )
)

echo =========================================
echo linking finished
