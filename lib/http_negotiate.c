/***************************************************************************
 *                                  _   _ ____  _
 *  Project                     ___| | | |  _ \| |
 *                             / __| | | | |_) | |
 *                            | (__| |_| |  _ <| |___
 *                             \___|\___/|_| \_\_____|
 *
 * Copyright (C) 1998 - 2019, Daniel Stenberg, <daniel@haxx.se>, et al.
 *
 * This software is licensed as described in the file COPYING, which
 * you should have received as part of this distribution. The terms
 * are also available at https://curl.haxx.se/docs/copyright.html.
 *
 * You may opt to use, copy, modify, merge, publish, distribute and/or sell
 * copies of the Software, and permit persons to whom the Software is
 * furnished to do so, under the terms of the COPYING file.
 *
 * This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
 * KIND, either express or implied.
 *
 ***************************************************************************/

#include "curl_setup.h"

#if !defined(CURL_DISABLE_HTTP) && defined(USE_SPNEGO)

#include "urldata.h"
#include "sendf.h"
#include "http_negotiate.h"
#include "vauth/vauth.h"

/* The last 3 #include files should be in this order */
#include "curl_printf.h"
#include "curl_memory.h"
#include "memdebug.h"

CURLcode Curl_input_negotiate(struct connectdata *conn, bool proxy,
                              const char *header)
{
  CURLcode result;
  struct Curl_easy *data = conn->data;
  size_t len;

  /* Point to the username, password, service and host */
  const char *userp;
  const char *passwdp;
  const char *service;
  const char *host;

  /* Point to the correct struct with this */
  struct negotiatedata *neg_ctx;

  if(proxy) {
    userp = conn->http_proxy.user;
    passwdp = conn->http_proxy.passwd;
    service = data->set.str[STRING_PROXY_SERVICE_NAME] ?
              data->set.str[STRING_PROXY_SERVICE_NAME] : "HTTP";
    host = conn->http_proxy.host.name;
    neg_ctx = &conn->proxyneg;
  }
  else {
    userp = conn->user;
    passwdp = conn->passwd;
    service = data->set.str[STRING_SERVICE_NAME] ?
              data->set.str[STRING_SERVICE_NAME] : "HTTP";
    host = conn->host.name;
    neg_ctx = &conn->negotiate;
  }

  /* Not set means empty */
  if(!userp)
    userp = "";

  if(!passwdp)
    passwdp = "";

  /* Obtain the input token, if any */
  header += strlen("Negotiate");
  while(*header && ISSPACE(*header))
    header++;

  len = strlen(header);
  neg_ctx->havenegdata = len != 0;
  if(!len) {
    if(neg_ctx->state == GSS_AUTHSUCC) {
      infof(conn->data, "Negotiate auth restarted\n");
      Curl_cleanup_negotiate(conn);
    }
    else if(neg_ctx->state != GSS_AUTHNONE) {
      /* The server rejected our authentication and hasn't supplied any more
      negotiation mechanisms */
      Curl_cleanup_negotiate(conn);
      return CURLE_LOGIN_DENIED;
    }
  }

  /* Supports SSL channel binding for Windows ISS extended protection */
#if defined(USE_WINDOWS_SSPI) && defined(SECPKG_ATTR_ENDPOINT_BINDINGS)
  neg_ctx->sslContext = conn->sslContext;
#endif

  /* Initialize the security context and decode our challenge */
  result = Curl_auth_decode_spnego_message(data, userp, passwdp, service,
                                           host, header, neg_ctx);

  if(result)
    Curl_auth_spnego_cleanup(neg_ctx);

  return result;
}

CURLcode Curl_output_negotiate(struct connectdata *conn, bool proxy)
{
  struct negotiatedata *neg_ctx = proxy ? &conn->proxyneg :
    &conn->negotiate;
  struct auth *authp = proxy ? &conn->data->state.authproxy :
    &conn->data->state.authhost;
  char *base64 = NULL;
  size_t len = 0;
  char *userp;
  CURLcode result;

  authp->done = FALSE;

  if(neg_ctx->state == GSS_AUTHRECV) {
    if(neg_ctx->havenegdata) {
      neg_ctx->havemultiplerequests = TRUE;
    }
  }
  else if(neg_ctx->state == GSS_AUTHSUCC) {
    if(!neg_ctx->havenoauthpersist) {
      neg_ctx->noauthpersist = !neg_ctx->havemultiplerequests;
    }
  }

  if(neg_ctx->noauthpersist ||
    (neg_ctx->state != GSS_AUTHDONE && neg_ctx->state != GSS_AUTHSUCC)) {

    if(neg_ctx->noauthpersist && neg_ctx->state == GSS_AUTHSUCC) {
      infof(conn->data, "Curl_output_negotiate, "
       "no persistent authentication: cleanup existing context");
      Curl_auth_spnego_cleanup(neg_ctx);
    }
    if(!neg_ctx->context) {
      result = Curl_input_negotiate(conn, proxy, "Negotiate");
      if(result)
        return result;
    }

    result = Curl_auth_create_spnego_message(conn->data,
      neg_ctx, &base64, &len);
    if(result)
      return result;

    userp = aprintf("%sAuthorization: Negotiate %s\r\n", proxy ? "Proxy-" : "",
      base64);

    if(proxy) {
      Curl_safefree(conn->allocptr.proxyuserpwd);
      conn->allocptr.proxyuserpwd = userp;
    }
    else {
      Curl_safefree(conn->allocptr.userpwd);
      conn->allocptr.userpwd = userp;
    }

    free(base64);

    if(userp == NULL) {
      return CURLE_OUT_OF_MEMORY;
    }

    neg_ctx->state = GSS_AUTHSENT;
  #ifdef HAVE_GSSAPI
    if(neg_ctx->status == GSS_S_COMPLETE ||
       neg_ctx->status == GSS_S_CONTINUE_NEEDED) {
      neg_ctx->state = GSS_AUTHDONE;
    }
  #else
  #ifdef USE_WINDOWS_SSPI
    if(neg_ctx->status == SEC_E_OK ||
       neg_ctx->status == SEC_I_CONTINUE_NEEDED) {
      neg_ctx->state = GSS_AUTHDONE;
    }
  #endif
  #endif
  }

  if(neg_ctx->state == GSS_AUTHDONE || neg_ctx->state == GSS_AUTHSUCC) {
    /* connection is already authenticated,
     * don't send a header in future requests */
    authp->done = TRUE;
  }

  neg_ctx->havenegdata = FALSE;

  return CURLE_OK;
}

void Curl_cleanup_negotiate(struct connectdata *conn)
{
  Curl_auth_spnego_cleanup(&conn->negotiate);
  Curl_auth_spnego_cleanup(&conn->proxyneg);
}

#endif /* !CURL_DISABLE_HTTP && USE_SPNEGO */
