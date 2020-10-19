# Tests

## Make a valid request

1. Change the hard-coded Auth server response to one of the following

**OT30**
```
    return 200 ' {
      "valid": true,
      "type": "OT30", 
      "redirect": null,
      "message": null
      }';
```

**OT31**
```
    return 200 ' {
      "valid": true,
      "type": "OT30", 
      "redirect": null,
      "message": null
      }';
```

**X**
```
    return 200 ' {
      "valid": true,
      "type": "x", 
      "redirect": null,
      "message": null
      }';
```

2. Then make the following curl request

```
curl -X POST -H "Content-Type: text/xml" \
    -H 'SOAPAction: "http://localhost"' \
    --data-binary @valid_request.xml \
    http://localhost
```

## Make a invalid request

1. Make the following curl request

```
curl -X POST -H "Content-Type: text/xml" \
    -H 'SOAPAction: "http://localhost"' \
    --data-binary @invalid_request.xml \
    http://localhost
```


## Get a unknown response

1. Change the hard-coded Auth server response to one of the following

**unknown**
```
    return 200 ' {
      "valid": true,
      "type": "unknown", 
      "redirect": null,
      "message": null
      }';
```

2. Then make the following curl request

```
curl -X POST -H "Content-Type: text/xml" \
    -H 'SOAPAction: "http://localhost"' \
    --data-binary @ivalid_request.xml \
    http://localhost
```