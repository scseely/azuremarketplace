const AUTH_INFO_KEY = 'authInfo';
const TOKEN_PARAM = 'token';
const BEARER_PARAM = 'bearer';

function fillInUserIdentity(authInfo, pageUrl){
    let hashString = '?' + pageUrl.hash.substr(1);
    let urlParams = new URLSearchParams(hashString);
    if (urlParams.has(TOKEN_PARAM)) {
        authInfo.rawToken = urlParams.get(TOKEN_PARAM);
        let tokenParam = decodeURIComponent(authInfo.rawToken);
        authInfo.authJwt = JSON.parse(tokenParam);
        if (authInfo.authJwt.hasOwnProperty('authenticationToken')) {
            authInfo.token = authInfo.authJwt.authenticationToken;
            authInfo.loggedIn = true;
        }

        history.pushState("", document.title, window.location.pathname + window.location.search);
    }

    return authInfo;
}

function saveAuthInfo(authInfo) {
    let authInfoString = JSON.stringify(authInfo);
    sessionStorage.setItem(AUTH_INFO_KEY, authInfoString);
}

function setupAuth() {
    let authInfo = sessionStorage.getItem(AUTH_INFO_KEY);
    let pageUrl = new URL(window.location.href);

    if (authInfo != null){
        authInfo = JSON.parse(authInfo);
        if (!authInfo.rawToken && pageUrl.hash){
            authInfo = fillInUserIdentity(authInfo, pageUrl);
            saveAuthInfo(authInfo);
        }

        return authInfo;
    }

    let redirectUrl = pageUrl.origin + pageUrl.pathname + pageUrl.search;
    let encodedUrl = encodeURIComponent(redirectUrl);
    let bearer = '';

    if (pageUrl.searchParams.has(BEARER_PARAM)){
        bearer = pageUrl.searchParams.get(BEARER_PARAM);
        sessionStorage.setItem(BEARER_PARAM, bearer);
    } else {
        bearer = sessionStorage.getItem(BEARER_PARAM);
    }

    // TODO: encode state into the azureLoginUrl
    let promptConsent = window.requireConsent ? '&prompt=consent' : '';
    authInfo = {
        token: '',
        bearer: bearer,
        rawToken: '',
        authJwt: {},
        loginUrl: window.appBaseUrl +
            '/.auth/login/aad?session_mode=token' + promptConsent + '&post_login_redirect_url=' + encodedUrl,
        loggedIn: false,
    };

    saveAuthInfo(authInfo);
    return authInfo;
}

function login() {
    console.log("Redirecting to " + window.auth.loginUrl);
    window.location.href = window.auth.loginUrl;
}

function logout() {
    sessionStorage.removeItem(AUTH_INFO_KEY);
    window.location.reload();
}
