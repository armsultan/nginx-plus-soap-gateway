# Make a valid request
curl -X POST -H "Content-Type: text/xml" \
    -H 'SOAPAction: "http://localhost"' \
    --data-binary @valid_request.xml \
    http://localhost


# Make a invalid request
curl -X POST -H "Content-Type: text/xml" \
    -H 'SOAPAction: "http://localhost"' \
    --data-binary @ivalid_request.xml \
    http://localhost