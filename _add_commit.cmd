rem echo %~dp0


set msgforcommit= qqqq
set fn=commitMsg.txt
if exist %fn% (


FOR /F  "tokens=*"  %%i IN (%fn%) DO (

set "msgforcommit=%%i" 

)


)

SET msgforcommit=%msgforcommit: =_% 

rem copy nul  %fn%

cd %~dp0
git add .
git commit -m %msgforcommit%

copy nul  %fn%
rem pause