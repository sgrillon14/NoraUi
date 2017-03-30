cd $(dirname $0)
cd ..
mvn clean test javadoc:javadoc -Dcucumber.options="--tags @hello,@bonjour,@blog,@playToLogoGame,@jouerAuJeuDesLogos" -PscenarioInitiator,javadoc,unit-tests -Dmaven.test.failure.ignore=true

curl -s "https://api.travis-ci.org/jobs/${TRAVIS_JOB_ID}/log.txt?deansi=true" > nonaui.log

expectation=`sed -n 's:.*<EXPECTED_RESULTS>\(.*\)</EXPECTED_RESULTS>.*:\1:p' nonaui.log | head -n 1`
nb_expectation=`sed -n ":;s/$expectation//p;t" nonaui.log | sed -n '$='`

if [ "$nb_expectation" == "2" ]; then
    echo "******** All counter is SUCCESS"
else
    echo "******** All counter is FAIL"
    exit 255
fi

exit 0
