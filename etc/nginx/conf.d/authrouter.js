
// **Start redundant**
// get_invalid() function is not used because we are parsing the request body in
// NGINX itself using regex on the $request_body varible
function get_invalid(r) {

    var regex = /wsse:InvalidField/;
    var body = r.requestBody;
}
// **End redundant**

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

    // **Start redundant**
    // This does not fire off because a subrequest made does not pass
    // the body
    if (r.variables.invalid == "true") {
        r.error("HERE I AM");

        r.headersOut['type'] = "error";
        r.return(200);
    }
    // **End redundant**

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