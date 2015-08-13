http = require('https')
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = '0'

class Jira
  constructor: (version = 2) ->
    @username = process.env.JIRA_USERNAME or process.env.ATLASSIAN_USERNAME or ''
    @password = process.env.JIRA_PASSWORD or process.env.ATLASSIAN_PASSWORD or ''
    @host = process.env.JIRA_HOST or process.env.ATLASSIAN_HOST or ''
    @context = process.env.JIRA_CONTEXT or ''
    @version = process.env.JIRA_API_VERSION or version

  getIssue: (issueID, params = {}, callback) ->
    params.jql = "issue=#{issueID}"
    @_request "GET", "issue/#{issueID}", params, null, callback

  createIssue: (issue, params = {}, callback) ->
    @_request "POST", "issue", params, issue, callback

  createRemoteLink: (issueKey, url, title, callback) ->
    body = object:
        url: url
        title: title
    @_request "POST", "issue/#{issueKey}/remotelink", null, body, callback

  setAssignee: (issueKey, assignee, callback) ->
    body = name: assignee
    @_request "PUT", "issue/#{issueKey}/assignee", null, body, callback

  simpleSearch: (query, params = {}, callback) ->
    params.jql = "text~#{query}"
    @_request "GET", "search", params, null, callback

  advancedSearch:(jql, params = {}, callback) ->
    params.jql = jql
    @_request "GET", "search", params, null, callback

  #  utils
  _request:(method, api, params, payload, callback) ->

    if params == null
      params = ''
    else
      params = toURL(params)

    payloadString = JSON.stringify(payload)

    options =
      host: @host
      path: "#{@context}/rest/api/#{@version}/#{api}#{params}"
      method: method
      auth: "#{@username}:#{@password}"
      headers:
        'Content-Type': 'application/json'
        'Content-Length': payloadString.length

    req = http.request options, (res) ->

      console.log options.path
      console.log payloadString

      res.setEncoding 'utf8'
      response = ''

      res.on 'data', (data) ->
        response += data

      res.on 'end', ->
        try
          jsonResponse = JSON.parse response
        catch e
          return callback "Could not parse as JSON response. #{e}. Received #{response}"

        if res.statusCode > 300
          msg = "[ERROR] #{res.statusCode}: #{res.statusMessage}"

          if jsonResponse.message?
            msg += "\n[ERROR] Message: #{jsonResponse.message}"

          return callback msg, jsonResponse
        else
          return callback null, jsonResponse

    req.on 'error', (e) ->
      console.log "HTTPS ERROR: #{e}"

    req.write payloadString
    req.end

toURL = (obj)->
  '?' + Object.keys(obj).map((k) ->
    encodeURIComponent(k) + '=' + encodeURIComponent(obj[k])
  ).join('&')

module.exports = new Jira()
