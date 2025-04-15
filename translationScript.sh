#!/bin/bash

projectName=${PWD##*/}
translationPath=./Ressources/Translations
binPath=${CDRIVE}/Qt/5.15.2/msvc2019_64/bin

mkdir -p ${translationPath}/
${binPath}/lupdate.exe -recursive -no-obsolete ./ -ts ${translationPath}/${projectName}_fr.ts
${binPath}/lrelease.exe ${translationPath}/${projectName}_fr.ts ${translationPath}/${projectName}_fr.qm
