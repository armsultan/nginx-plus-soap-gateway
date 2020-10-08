function get_env(r) {
    r.subrequest('/env_endpoint')
    .then(reply => JSON.parse(reply.responseBody))
    .then(json => { 
        r.headersOut['type'] = json.environment; 
        r.return(200);
    })
    .catch(e => r.return(500, e));
 }

export default {get_env};