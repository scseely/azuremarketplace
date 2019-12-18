function resolveBearer(bearer, token, success) {
    let resolveBearerUrl = window.apiBaseUrl + "/api/ResolveBearer";

    $('#noAuth').attr('class', 'hide')
    $('#loading').attr('class', 'show')

    $.post({
        url: resolveBearerUrl,
        data: JSON.stringify({
            authentication_token: token,
            bearer: bearer,
        }),
        dataType: 'json',
        headers: {
            'X-ZUMO-AUTH': token,
        },
        contentType: 'application/json',
        success: success
    });
}

function onError(xhr, status, error){
    console.log(status + "  " + error);
}

function activateOffer(bearer, token, subscriptionId, planId, success) {
    let activateOfferUrl = window.apiBaseUrl + "/api/ActivateOffer";

    $.post({
        url: activateOfferUrl,
        data: JSON.stringify({
            authentication_token: token,
            bearer: bearer,
            subscription_id: subscriptionId,
            plan_id: planId,
        }),
        dataType: 'text',
        headers: {
            'X-ZUMO-AUTH': token,
        },
        contentType: 'application/json',
        success: success,
        error: onError
    });
}

function listAvailablePlans(bearer, token, subscriptionId, success) {
    let listPlansUrl = window.apiBaseUrl + "/api/ListPlans";

    $.post({
        url: listPlansUrl,
        data: JSON.stringify({
            authentication_token: token,
            bearer: bearer,
            subscription_id: subscriptionId,
        }),
        dataType: 'json',
        headers: {
            'X-ZUMO-AUTH': token,
        },
        contentType: 'application/json',
        success: success
    });
}

function updateAzSubscription(subscriptionId, offerInfo.planId, activateSubscriptionSuccess);