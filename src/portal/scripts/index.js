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
    listAvailablePlans(authInfo.bearer, authInfo.token, offerInfo.id, listAvailablePlansSuccess);
}

function addBearerIfMissing() {
    if (window.debugging) {
        let pageUrl = new URL(window.location.href);
        if (pageUrl.searchParams.has(BEARER_PARAM)) {
            return false;
        }

        pageUrl.searchParams.append(BEARER_PARAM, 'someToken');

        window.location.href = pageUrl.toString();
        return true;
    }
    return false;
}

$(function(){
    if (addBearerIfMissing()) {
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
    activateOffer(authInfo.bearer, authInfo.token, offerInfo.id, offerInfo.planId, activateSubscriptionSuccess);
}

function updateSubscription() {
    
    let offerInfo = window.planInfo.offerInfo;
    let authInfo = window.auth;
    updateAzSubscription(authInfo.bearer, authInfo.token, offerInfo.id, offerInfo.planId, activateSubscriptionSuccess);
}