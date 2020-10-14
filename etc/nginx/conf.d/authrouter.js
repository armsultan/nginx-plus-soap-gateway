function get_invalid(r) {

    var regex = /wsse:InvalidField/;
    var body = r.requestBody;
    // return regex.test(body);

    if (regex.test(body)) {
        return "1";
    }
    else {
        return "0";
    }
}

function get_username(r) {
    var body = r.requestBody;
    var regex = /<wsse:Username>(?<u>.*)<\/wsse:Username>/;
    return regex.exec(body)[1];

}

function get_password(r) {
    var body = r.requestBody;
    var regex = /<wsse:Password.*>(?<p>.*)<\/wsse:Password>/;
    return regex.exec(body)[1];
}

function get_type(r) {

    r.subrequest('/env_endpoint', JSON.stringify({ created: "2020-08-12T17:46:35.942Z", nonce: 1, origin: "localhost", password: r.variables.password, requestedMethod: "", requestedUri: "", username: r.variables.username }))
        .then(reply => {
            r.error(reply.responseBody);
            var json = JSON.parse(reply.responseBody);
            r.error(json.type);
            r.headersOut['type'] = json.type;
            r.return(200);
        })
        .catch(e => {
            r.error(e);
            r.return(500, e);
        });
}

export default { get_invalid, get_username, get_password, get_type };