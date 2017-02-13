###*
 * source: jsonp.coffee
###

###
 * 
 * Copyright 2017 Al Carruth
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
###

___dummy___ = 'ignore this !-)'

### Class JSONP_Controller ###
###*
 * A JSONP_Controller instance can be used to make a jsonp request to an api server.
 * @constructor
 * @param {string} base_URL - the base url for the server
 * @param {string} cb_Prefix - used in naming the jsonp callback function
###
class JSONP_Controller

    ### constructor ###
    constructor: (@base_URL, @cb_Prefix) ->
        @cb_Prefix = @cb_Prefix || 'jsonp_Callback_'
        ### seq_ID is appended to the cb_Prefix ###
        @seq_ID = 0
        ### collect the requests for later inspection (maybe?) ###
        @requests = []
        
    ###*
     * method make_Request()
     * returns a JSONP_Request object
     * @param {object} obj - query, success, error, msec
    ###
    make_Request: (obj) =>

        ### the call back function name, unique to this call ###
        cb_Name = @cb_Prefix + @seq_ID++
        
        ### ADD 'CALLBACK' TO provided query object ###
        obj.query.callback = cb_Name

        ### construct the url from the base_URL and the query object ###
        url = @base_URL
        keys = Object.keys(obj.query)
        url += (key+'='+obj.query[key] for key in keys).join('&')
        url = encodeURI(url)

        request = new JSONP_Request(obj.success, obj.error, obj.msec, cb_Name, url)
        @requests.push(request)
        return request

        
### Class JSONP_Request ###
###*
 * A JSONP_Request object is used to make a jsonp request to an api server.
 * @constructor
 * @param {function} success - executed upon successful jsonp response
 * @param {function} error - executed upon timeout
 * @param {int} msec - timeout delay in milliseconds
 * @param {string} cb_Name 
 * @param {string} url - the url for jsonp call
###
class JSONP_Request

    ### constructor ###
    constructor: (@success, @error, @msec, @cb_Name, @url) ->
        
        ### the parent node to be ###
        @head = document.getElementsByTagName('head')[0]
        
        ### the script element that enables this request ###
        @elt = document.createElement('script')
        @elt.type = 'text/javascript'
        @elt.async = true
        @elt.src = @url

        ### the below might be useful later, idk ###
        @elt.id = @cb_Name
        @elt.className = 'jsonp-request'
        @elt.request = this

    ### method callback() ###
    callback: (data) =>
        window.clearTimeout(@timeout)
        @success(data)

    ### method send() ###
    send: =>
        window[@cb_Name] = @callback
        @timeout = window.setTimeout(@error, @msec)
        ### appending @elt triggers the call to fetch the jsonp script ###
        @head.appendChild(@elt)


if window?
    window.JSONP_Controller = JSONP_Controller
