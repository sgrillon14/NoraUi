#!/usr/bin/env bash

#
# take noraui-datas-webservices from Maven Central and Start Web Services (REST)
wget -O noraui-datas-webservices-1.0.0.jar 'https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=com.github.noraui&a=noraui-datas-webservices&v=1.0.0-SNAPSHOT&p=jar'

java -jar noraui-datas-webservices-1.0.0.jar &
PID=$!
sleep 30
curl -s --header "Accept: application/json" http://localhost:8084/noraui/api/hello/columns > actual_hello_columns.json
curl -s --header "Accept: application/xml" http://localhost:8084/noraui/api/hello/columns > actual_hello_columns.xml

ls -l

echo "Let's look at the actual results: `cat actual_hello_columns.json`"
echo "And compare it to: `cat test/expected_hello_columns.json`"
if diff -w test/expected_hello_columns.json actual_hello_columns.json
    then
        echo SUCCESS
        let ret=0
    else
        echo FAIL
        let ret=255
        exit $ret
fi

echo "Let's look at the actual results: `cat actual_hello_columns.xml`"
echo "And compare it to: `cat test/expected_hello_columns.xml`"
if diff -w test/expected_hello_columns.xml actual_hello_columns.xml
    then
        echo SUCCESS
        let ret=0
    else
        echo FAIL
        let ret=255
        exit $ret
fi
echo "******** noraui-datas-webservices STARTED"

# take noraui-datas-webservices from Maven Central and Start Web Services (REST)
wget -O countries-app-sample-0.0.1.jar 'https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=com.github.noraui&a=countries-app-sample&v=0.0.1-SNAPSHOT&p=jar'

java -jar countries-app-sample-0.0.1.jar &
PIDcountries=$!
sleep 30

git clone --bare https://github.com/NoraUi/countries-app-sample.git
#
#
# start NoraUi part =>
cd $(dirname $0)
cd ..
if [ "$TRAVIS_REPO_SLUG" == 'NoraUi/NoraUi' ] && [ "$TRAVIS_BRANCH" == 'master' ] && [ "$TRAVIS_PULL_REQUEST" == 'false' ]; then
    mvn -e -U clean org.jacoco:jacoco-maven-plugin:prepare-agent package javadoc:javadoc sonar:sonar -Dsonar.host.url=https://sonarcloud.io -Dsonar.organization=noraui -Dsonar.login=$SONAR_TOKEN -Dcucumber.options="--tags '@hello or @bonjour or @blog or @playToLogoGame or @jouerAuJeuDesLogos or @sampleRESTAPI'" -PscenarioInitiator,javadoc,unit-tests --settings test/mvnsettings.xml -Dmaven.test.failure.ignore=true -Dcrypto.key=${CRYPTO_KEY}
else
    mvn -e -U clean package javadoc:javadoc -Dpullrequest -Dcucumber.options="--tags '@hello or @bonjour or @blog or @playToLogoGame or @jouerAuJeuDesLogos or @sampleRESTAPI'" -PscenarioInitiator,javadoc,unit-tests --settings test/mvnsettings.xml -Dmaven.test.failure.ignore=true -Dcrypto.key=my-secret
fi

#
# kill Web Services (REST)
kill -9 $PID
echo "******** noraui-datas-webservices STOPED"

#
# kill countries Application
kill -9 $PIDcountries
echo "******** countries-app-sample STOPED"

#
# read Maven console
curl -s "https://api.travis-ci.org/jobs/${TRAVIS_JOB_ID}/log.txt?deansi=true" > nonaui.log

# check if BUILD FAILURE finded in logs
nb_failure=$(sed -n ":;s/BUILD FAILURE//p;t" nonaui.log | sed -n '$=')
if [ "$nb_failure" != "" ]; then
    echo "******** BUILD FAILURE find $nb_failure time in build"
    echo "******** BUILD FAILURE find $nb_failure time in build"
    exit 255
fi

echo "***************************************************"

counters1=$(sed -n 's:.*\[Excel\] > <EXPECTED_RESULTS_1>\(.*\)</EXPECTED_RESULTS_1>.*:\1:p' nonaui.log | head -n 1)
echo "******** $counters1"
nb_counters1=$(sed -n ":;s/$counters1//p;t" nonaui.log | sed -n '$=')
echo "********" found $nb_counters1 times

counters2=$(sed -n 's:.*\[Excel\] > <EXPECTED_RESULTS_2>\(.*\)</EXPECTED_RESULTS_2>.*:\1:p' nonaui.log | head -n 1)
echo "******** $counters2"
nb_counters2=$(sed -n ":;s/$counters2//p;t" nonaui.log | sed -n '$=')
echo "******** found $nb_counters2 times"

echo "***************************************************"

# 3 = 1 (real) + 2 counters (Excel and CSV)
if [ "$nb_counters1" == "3" ] && [ "$nb_counters2" == "3" ]; then
    echo "******** All counter is SUCCESS"
else
    echo "******** All counter is FAIL"
    echo "$counters1 found $nb_counters1 times"
    echo "$counters2 found $nb_counters2 times"
    pwd
    ls -l
    cat target/reports/html/index.html
    exit 255
fi

echo ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,**/*/(##(*,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,/##//*,,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,***////###/,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*/*/////(###*,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///#/////(###,,,,,,,,,,,,,,,,,,,,,,,,,,,,**/(***,,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///##(/////###(,,,,,,,,,,,,,,,,,,,,,,,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(**////###/,,,,,,,,,,,,,,,,,,,,,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,*////(##(*,,,,,,,,,,,,,,,,,,,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,*////(##(*,,,,,,,,,,,,,,,,,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,**////###/,,,,,,,,,,,,,,,,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,,,*////(###*,,,,,,,,,,,,,,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,,,,,*////(##(,,,,,,,,,,,,,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,,,,,,**////###(,,,,,,,,,,,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,,,,,,,,**////###/,,,,,,,,,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,,,,,,,,,,*////(##(*,,,,,,,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,,,,,,,,,,,,*////(##(,,,,,,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,,,,,,,,,,,,,**///(###/,,,,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,,,,,,,,,,,,,,,*////(###*,,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,,,,,,,,,,,,,,,,,*////###(,,,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,,,,,,,,,,,,,,,,,,**//*/###(,,(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,,,,,,,,,,,,,,,,,,,,**///(###/(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,,,,,,,,,,,,,,,,,,,,,,*////(######///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,,,,,,,,,,,,,,,,,,,,,,,,*////#####///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*///*(###///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///###(********************************////(#///*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*///####################################(////////*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*//////////////////////////////////////////*///*/*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,*//////////////////////////////////////////**/**/*,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,,,,,,,,**,,,,**,,,,,,,,,,,,,,,,,,,/,,,,,*,/*,,,,,,,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,,,,,,,,/(#,,,*/,,,**,,,,,,,,,,*,,,#,,,,*/,,,,,,,,,,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,,,,,,,,/*,%*,*/,#/,,*#,/#,,,*,,/*,#,,,,*/,#*,,,,,,,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,,,,,,,,/*,,//*/,#,,,,(*/*,,,#(*/*,#*,,,*/,#*,,,,,,,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,,,,,,,,/*,,,*%/,(#,,((,/*,,*/,*#*,/%*,/#,,#*,,,,,,,,,,,,,,,,,,,,"
echo ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"

exit 0
