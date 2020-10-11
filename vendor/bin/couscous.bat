@ECHO OFF
setlocal DISABLEDELAYEDEXPANSION
SET BIN_TARGET=%~dp0/../couscous/couscous/bin/couscous
php "%BIN_TARGET%" %*
