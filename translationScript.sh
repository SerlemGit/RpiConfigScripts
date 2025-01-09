#!/bin/bash

projectName=${PWD##*/}
translationPath=./Ressources/Translations

mkdir -p ${translationPath}/
${CDRIVE}/Qt/5.11.3/msvc2017_64/bin/lupdate.exe -recursive -no-obsolete ./ -ts ${translationPath}/${projectName}_fr.ts
${CDRIVE}/Qt/5.11.3/msvc2017_64/bin/lrelease.exe ${translationPath}/${projectName}_fr.ts ${translationPath}/${projectName}_fr.qm
