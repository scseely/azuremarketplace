function resolveBearerSuccess(data) {
    window.planInfo = {
        offerInfo: data.resolve_result,
        userInfo: data.easy_auth_result,
    };

    let offerInfo = window.planInfo.offerInfo;
    let userInfo = window.planInfo.userInfo;

    $('#subscriptionId').html(offerInfo.id);
    $('#subscriptionName').html(offerInfo.subscriptionName);
    $('#offerId').html(offerInfo.offerId);
    $('#planId').html(offerInfo.planId);
    $('#subscriberName').html(userInfo.name);
    $('#subscriberEmail').html(userInfo.email);
    $('#subscriberTenant').html(userInfo.tenant);

    $('#loading').attr('class', 'hide');
    $('#auth').attr('class', 'show');

}

function listAvailablePlansSuccess(data) {
    let plans = data.plans;
    for (let i = 0; i < plans.length; ++i) {
        let plan = plans[i];
        let option = new Option(plan.displayName, plan.planId);
        $('#selectPlan').append(option);
    }

    $('#preActivation').attr('class', 'hide');
    $('#postActivation').attr('class', 'show');
}

function activateSubscriptionSuccess(data) {
    let offerInfo = window.planInfo.offerInfo;
    let authInfo = window.auth;
    listAvailablePlans(authInfo.token, offerInfo.id, listAvailablePlansSuccess);
}

function addTokenIfMissing() {
    if (window.debugging) {
        let pageUrl = new URL(window.location.href);
        let hashString = '?' + pageUrl.hash.substr(1);
        let urlParams = new URLSearchParams(hashString);
        if (urlParams.has(TOKEN_PARAM)){
            return false;
        }
        if (pageUrl.searchParams.has(TOKEN_PARAM)) {
            return false;
        }
        localStorage.clear();
        sessionStorage.clear();
        pageUrl.searchParams.append(TOKEN_PARAM, '7r%2B8p4QuaEnrQk45SJjNw6g8abMe3Goe6B8vKpn6LglOq%2Bmef%2FL77K45%2BetH5Lbu3%2Fz7H3Xhte7MHlhRCpKURnjPa35x49oq5Kp7OHCR8AsFO2AiWK3LhvhQOENIK5OOO%2F3RlfAxPj8snZW%2F4Z90sv4gq42EglGjHgHck0sfjNwNoZ2%2FhzWwfzh02Gzik4jf0JNikL2kX1M840FtgtymYVcZueRR%2BsrkyEVksw35NNLSCJ3Yy0HS9vaSnVubWTWo3%2BAYTeqw8%2FZZOZHxp9AMlA%3D%3D');

        window.location.href = pageUrl.toString();
        return true;
    }
    return false;
}

$(function(){
    if (addTokenIfMissing()) {
        return;
    }

    let authInfo = setupAuth();
    window.auth = authInfo;

    if (window.authEnabled){
        if (window.auth.loggedIn) {
            if (window.auth.bearer.length > 0) {
                console.log('resolving bearer');
                resolveBearer(window.auth.bearer, window.auth.token, resolveBearerSuccess);
            } else {
                console.log("no bearer!");
            }
        } else if (window.autoLogin) {
            window.location.href = window.auth.loginUrl;
        } else {
            console.log('not logged in.');
        }
    } else {
        console.log('auth not enabled');
    }

});

function clearStorage() {
    localStorage.clear();
    sessionStorage.clear();
    window.location.reload();
}

function activateSubscription() {
    let offerInfo = window.planInfo.offerInfo;
    let authInfo = window.auth;
    activateOffer(authInfo.token, offerInfo.id, offerInfo.planId, activateSubscriptionSuccess);
}

function updateSubscription() {
    
    let offerInfo = window.planInfo.offerInfo;
    let authInfo = window.auth;
    updateAzSubscription(authInfo.bearer, authInfo.token, offerInfo.id, offerInfo.planId, activateSubscriptionSuccess);
}