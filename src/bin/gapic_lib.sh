#!/bin/zsh

gapicSets=( asps channels chromeosdevices customers domainAliases domains groups members mobiledevices orgunits privileges roleAssignments roles schemas tokens twoStepVerification users verificationCodes )

asps=( asps_delete asps_get asps_list )
channels=( channels_stop )
chromeosdevices=( chromeosdevices_action chromeosdevices_get chromeosdevices_list chromeosdevices_moveDevicesToOu chromeosdevices_patch chromeosdevices_update )
customers=( customers_get customers_patch customers_update )
domainAliases=( domainAliases_delete domainAliases_get domainAliases_insert domainAliases_list )
domains=( domains_delete domains_get domains_insert domains_list )
groups=( groups_delete groups_get groups_insert groups_list groups_patch groups_update )
members=( members_delete members_get members_hasMember members_insert members_list members_patch members_update )
mobiledevices=( mobiledevices_action mobiledevices_delete mobiledevices_get mobiledevices_list )
orgunits=( orgunits_delete orgunits_get orgunits_insert orgunits_list orgunits_patch orgunits_update )
privileges=( privileges_list )
roleAssignments=( roleAssignments_delete roleAssignments_get roleAssignments_insert roleAssignments_list )
roles=( roles_delete roles_get roles_insert roles_list roles_patch roles_update )
schemas=( schemas_delete schemas_get schemas_insert schemas_list schemas_patch schemas_update )
tokens=( tokens_delete tokens_get tokens_list )
twoStepVerification=( twoStepVerification_turnOff )
users=( users_delete users_get users_insert users_list users_makeAdmin users_patch users_signOut users_undelete users_update users_watch )
verificationCodes=( verificationCodes_generate verificationCodes_invalidate verificationCodes_list )

getParams() {
    local tempPar=${1}
    local urlVar=${2}

    local tempCarrier=PARAM_${tempPar}
    local tempMeta=${tempPar}Meta
    local tempVal="${(P)tempPar}"

    if [[ -z ${(P)${tempMeta}[3]} ]]
    then
        echo -en "# Please supply a value for the ${tempPar} parameter (${(P)${tempMeta}[1]}).\n#\n# Desc: ${(P)${tempMeta}[2]}\n~> "
        read -r ${tempVal}
        export ${tempVal}
        clear

    else
        tempOpts=(`echo ${(P)${tempMeta}[3]} | jq -r ".[]"`)
        echo -en "# Please supply a value for the ${tempPar} parameter (${(P)${tempMeta}[1]}).\n#\n# Desc: ${(P)${tempMeta}[2]}\n~> "
        select getOption in ${tempOpts}
        do
            if [[ -n ${getOption} ]]
            then
                declare -g "tempVal=${getOption}"
                clear
                break
            fi
        done
        unset getOption 
    fi
    unset tempParMeta

    if ! [[ -z "${tempVal}" ]]
    then

        declare -g "${tempPar}=${tempVal}"
        if [[ "${urlVar}" =~ "true" ]]
        then
            declare -g "tempUrlPar=&${tempPar}=${(P)${tempPar}}"
        fi

    fi

    if [[ -f ${credFileParams} ]]
    then
        if ! [[ `grep "${tempCarrier}" ${credFileParams}` ]]
        then 
            cat << EOIF >> ${credFileParams}
${tempCarrier}=( ${(P)${tempPar}} )
EOIF
        else 
            if ! [[ `egrep "\<${tempCarrier}\>.*\<${(P)${tempPar}}\>" ${credFileParams}` ]]
            then
                cat << EOIF >> ${credFileParams}
${tempCarrier}+=( ${(P)${tempPar}} )
EOIF
            fi
        fi
    else
        touch ${credFileParams}
        cat << EOIF >> ${credFileParams}
${tempCarrier}=( ${(P)${tempPar}} )
EOIF
    fi

    unset tempPar tempCarrier tempVal
}

### TODO
# fix error where you can't select non-saved paropts


checkParams() {
    local tempPar=${1}
    local urlVar=${2}

    tempCarrier=PARAM_${tempPar}
    echo -en "# You have saved values for the ${tempPar} parameter. Do you want to use one?\n\n"
    select checkOption in ${(P)${tempCarrier}} none
    do
        if [[ -n ${checkOption} ]]
        then
            if [[ ${checkOption} =~ "none" ]]
            then
                clear
                getParams ${tempPar} ${urlVar}
                break
            else
                clear
                declare -g "${tempPar}=${checkOption}"

                if [[ "${urlVar}" =~ "true" ]]
                then
                    declare -g "tempUrlPar=&${tempPar}=${(P)${tempPar}}"
                fi
                
                unset checkOption
                break
            fi
        
        fi
    done


    if [[ -z "${(P)${tempPar}}" ]]
    then
        getParams ${tempPar} ${urlVar}
    fi
    unset tempPar reuseParOpt tempCarrier
}


asps_delete() {


    codeIdMeta=( 
        'integer'
        'The unique ID of the ASP to be deleted.'
    )


    if [[ -z "${ASPS_DELETE_codeId}" ]]
    then
        if ! [[ -z "${PARAM_codeId}" ]]
        then 
            checkParams codeId "false"
            
        else
            getParams codeId
        fi
        declare -g "ASPS_DELETE_codeId=${codeId}"

    fi

    
    userKeyMeta=( 
        'string'
        'Identifies the user in the API request. The value can be the user'\''s primary email address, alias email address, or unique user ID.'
    )


    if [[ -z "${ASPS_DELETE_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "ASPS_DELETE_userKey=${userKey}"

    fi

    

    ASPS_DELETE_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}/asps/${codeId}?key=${CLIENTID}"


    curl -s \
        --request DELETE \
        ${ASPS_DELETE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request DELETE \\ 
        ${ASPS_DELETE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

asps_get() {


    codeIdMeta=( 
        'integer'
        'The unique ID of the ASP.'
    )


    if [[ -z "${ASPS_GET_codeId}" ]]
    then
        if ! [[ -z "${PARAM_codeId}" ]]
        then 
            checkParams codeId "false"
            
        else
            getParams codeId
        fi
        declare -g "ASPS_GET_codeId=${codeId}"

    fi

    
    userKeyMeta=( 
        'string'
        'Identifies the user in the API request. The value can be the user'\''s primary email address, alias email address, or unique user ID.'
    )


    if [[ -z "${ASPS_GET_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "ASPS_GET_userKey=${userKey}"

    fi

    

    ASPS_GET_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}/asps/${codeId}?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${ASPS_GET_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${ASPS_GET_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

asps_list() {


    userKeyMeta=( 
        'string'
        'Identifies the user in the API request. The value can be the user'\''s primary email address, alias email address, or unique user ID.'
    )


    if [[ -z "${ASPS_LIST_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "ASPS_LIST_userKey=${userKey}"

    fi

    

    ASPS_LIST_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}/asps?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${ASPS_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${ASPS_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

channels_stop() {



    CHANNELS_STOP_URL="https://www.googleapis.com/admin/directory_v1/channels/stop?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${CHANNELS_STOP_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${CHANNELS_STOP_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

chromeosdevices_action() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${CHROMEOSDEVICES_ACTION_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "CHROMEOSDEVICES_ACTION_customerId=${customerId}"

    fi

    
    resourceIdMeta=( 
        'string'
        'Immutable ID of Chrome OS Device'
    )


    if [[ -z "${CHROMEOSDEVICES_ACTION_resourceId}" ]]
    then
        if ! [[ -z "${PARAM_resourceId}" ]]
        then 
            checkParams resourceId "false"
            
        else
            getParams resourceId
        fi
        declare -g "CHROMEOSDEVICES_ACTION_resourceId=${resourceId}"

    fi

    

    CHROMEOSDEVICES_ACTION_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/devices/chromeos/${resourceId}/action?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${CHROMEOSDEVICES_ACTION_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${CHROMEOSDEVICES_ACTION_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

chromeosdevices_get() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${CHROMEOSDEVICES_GET_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "CHROMEOSDEVICES_GET_customerId=${customerId}"

    fi

    
    deviceIdMeta=( 
        'string'
        'Immutable ID of Chrome OS Device'
    )


    if [[ -z "${CHROMEOSDEVICES_GET_deviceId}" ]]
    then
        if ! [[ -z "${PARAM_deviceId}" ]]
        then 
            checkParams deviceId "false"
            
        else
            getParams deviceId
        fi
        declare -g "CHROMEOSDEVICES_GET_deviceId=${deviceId}"

    fi

    

    CHROMEOSDEVICES_GET_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/devices/chromeos/${deviceId}?key=${CLIENTID}"

    optParams=( projection )

    projectionMeta=(
        'string'
        'Restrict information returned to a set of selected fields.'
        '["PROJECTION_UNDEFINED","BASIC","FULL"]'
    )


    echo -en "# Would you like to define extra parameters? [y/n] \n${optParams}\n\n~> "
    read -r optParChoice
    clear


    if [[ ${optParChoice} =~ "y" ]] || [[ ${optParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#optParams[@]} ; i++ ))
        do

            select option in ${optParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            CHROMEOSDEVICES_GET_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            CHROMEOSDEVICES_GET_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam
                        
                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request GET \
        ${CHROMEOSDEVICES_GET_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${CHROMEOSDEVICES_GET_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

chromeosdevices_list() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${CHROMEOSDEVICES_LIST_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "CHROMEOSDEVICES_LIST_customerId=${customerId}"

    fi

    

    CHROMEOSDEVICES_LIST_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/devices/chromeos?key=${CLIENTID}"

    optParams=( orderBy projection sortOrder )

    orderByMeta=(
        'string'
        'Column to use for sorting results'
        '["orderByUndefined","annotatedLocation","annotatedUser","lastSync","notes","serialNumber","status","supportEndDate"]'
    )

    projectionMeta=(
        'string'
        'Restrict information returned to a set of selected fields.'
        '["PROJECTION_UNDEFINED","BASIC","FULL"]'
    )

    sortOrderMeta=(
        'string'
        'Whether to return results in ascending or descending order. Only of use when orderBy is also used'
        '["SORT_ORDER_UNDEFINED","ASCENDING","DESCENDING"]'
    )


    echo -en "# Would you like to define extra parameters? [y/n] \n${optParams}\n\n~> "
    read -r optParChoice
    clear


    if [[ ${optParChoice} =~ "y" ]] || [[ ${optParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#optParams[@]} ; i++ ))
        do

            select option in ${optParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            CHROMEOSDEVICES_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            CHROMEOSDEVICES_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam
                        
                        break
                    fi
                fi
            done
        done
    fi
    inpParams=( maxResults orgUnitPath pageToken query )

    maxResultsMeta=(
        'integer'
        'Maximum number of results to return.'
    )

    orgUnitPathMeta=(
        'string'
        'Full path of the organizational unit or its ID'
    )

    pageTokenMeta=(
        'string'
        'Token to specify next page in the list'
    )

    queryMeta=(
        'string'
        'Search string in the format given at http://support.google.com/chromeos/a/bin/answer.py?answer=1698333'
    )


    echo -en "# Would you like to define input parameters? [y/n] \n${inpParams}\n\n~> "
    read -r inpParChoice
    clear


    if [[ ${inpParChoice} =~ "y" ]] || [[ ${inpParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#inpParams[@]} ; i++ ))
        do

            select option in ${inpParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            CHROMEOSDEVICES_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            CHROMEOSDEVICES_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam

                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request GET \
        ${CHROMEOSDEVICES_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${CHROMEOSDEVICES_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

chromeosdevices_moveDevicesToOu() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${CHROMEOSDEVICES_MOVEDEVICESTOOU_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "CHROMEOSDEVICES_MOVEDEVICESTOOU_customerId=${customerId}"

    fi

    
    orgUnitPathMeta=( 
        'string'
        'Full path of the target organizational unit or its ID'
    )


    if [[ -z "${CHROMEOSDEVICES_MOVEDEVICESTOOU_orgUnitPath}" ]]
    then
        if ! [[ -z "${PARAM_orgUnitPath}" ]]
        then 
            checkParams orgUnitPath "false"
            
        else
            getParams orgUnitPath
        fi
        declare -g "CHROMEOSDEVICES_MOVEDEVICESTOOU_orgUnitPath=${orgUnitPath}"

    fi

    

    CHROMEOSDEVICES_MOVEDEVICESTOOU_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/devices/chromeos/moveDevicesToOu?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${CHROMEOSDEVICES_MOVEDEVICESTOOU_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${CHROMEOSDEVICES_MOVEDEVICESTOOU_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

chromeosdevices_patch() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${CHROMEOSDEVICES_PATCH_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "CHROMEOSDEVICES_PATCH_customerId=${customerId}"

    fi

    
    deviceIdMeta=( 
        'string'
        'Immutable ID of Chrome OS Device'
    )


    if [[ -z "${CHROMEOSDEVICES_PATCH_deviceId}" ]]
    then
        if ! [[ -z "${PARAM_deviceId}" ]]
        then 
            checkParams deviceId "false"
            
        else
            getParams deviceId
        fi
        declare -g "CHROMEOSDEVICES_PATCH_deviceId=${deviceId}"

    fi

    

    CHROMEOSDEVICES_PATCH_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/devices/chromeos/${deviceId}?key=${CLIENTID}"

    optParams=( projection )

    projectionMeta=(
        'string'
        'Restrict information returned to a set of selected fields.'
        '["PROJECTION_UNDEFINED","BASIC","FULL"]'
    )


    echo -en "# Would you like to define extra parameters? [y/n] \n${optParams}\n\n~> "
    read -r optParChoice
    clear


    if [[ ${optParChoice} =~ "y" ]] || [[ ${optParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#optParams[@]} ; i++ ))
        do

            select option in ${optParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            CHROMEOSDEVICES_PATCH_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            CHROMEOSDEVICES_PATCH_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam
                        
                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request PATCH \
        ${CHROMEOSDEVICES_PATCH_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PATCH \\ 
        ${CHROMEOSDEVICES_PATCH_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

chromeosdevices_update() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${CHROMEOSDEVICES_UPDATE_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "CHROMEOSDEVICES_UPDATE_customerId=${customerId}"

    fi

    
    deviceIdMeta=( 
        'string'
        'Immutable ID of Chrome OS Device'
    )


    if [[ -z "${CHROMEOSDEVICES_UPDATE_deviceId}" ]]
    then
        if ! [[ -z "${PARAM_deviceId}" ]]
        then 
            checkParams deviceId "false"
            
        else
            getParams deviceId
        fi
        declare -g "CHROMEOSDEVICES_UPDATE_deviceId=${deviceId}"

    fi

    

    CHROMEOSDEVICES_UPDATE_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/devices/chromeos/${deviceId}?key=${CLIENTID}"

    optParams=( projection )

    projectionMeta=(
        'string'
        'Restrict information returned to a set of selected fields.'
        '["PROJECTION_UNDEFINED","BASIC","FULL"]'
    )


    echo -en "# Would you like to define extra parameters? [y/n] \n${optParams}\n\n~> "
    read -r optParChoice
    clear


    if [[ ${optParChoice} =~ "y" ]] || [[ ${optParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#optParams[@]} ; i++ ))
        do

            select option in ${optParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            CHROMEOSDEVICES_UPDATE_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            CHROMEOSDEVICES_UPDATE_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam
                        
                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request PUT \
        ${CHROMEOSDEVICES_UPDATE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PUT \\ 
        ${CHROMEOSDEVICES_UPDATE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

customers_get() {


    customerKeyMeta=( 
        'string'
        'Id of the customer to be retrieved'
    )


    if [[ -z "${CUSTOMERS_GET_customerKey}" ]]
    then
        if ! [[ -z "${PARAM_customerKey}" ]]
        then 
            checkParams customerKey "false"
            
        else
            getParams customerKey
        fi
        declare -g "CUSTOMERS_GET_customerKey=${customerKey}"

    fi

    

    CUSTOMERS_GET_URL="https://www.googleapis.com/admin/directory/v1/customers/${customerKey}?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${CUSTOMERS_GET_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${CUSTOMERS_GET_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

customers_patch() {


    customerKeyMeta=( 
        'string'
        'Id of the customer to be updated'
    )


    if [[ -z "${CUSTOMERS_PATCH_customerKey}" ]]
    then
        if ! [[ -z "${PARAM_customerKey}" ]]
        then 
            checkParams customerKey "false"
            
        else
            getParams customerKey
        fi
        declare -g "CUSTOMERS_PATCH_customerKey=${customerKey}"

    fi

    

    CUSTOMERS_PATCH_URL="https://www.googleapis.com/admin/directory/v1/customers/${customerKey}?key=${CLIENTID}"


    curl -s \
        --request PATCH \
        ${CUSTOMERS_PATCH_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PATCH \\ 
        ${CUSTOMERS_PATCH_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

customers_update() {


    customerKeyMeta=( 
        'string'
        'Id of the customer to be updated'
    )


    if [[ -z "${CUSTOMERS_UPDATE_customerKey}" ]]
    then
        if ! [[ -z "${PARAM_customerKey}" ]]
        then 
            checkParams customerKey "false"
            
        else
            getParams customerKey
        fi
        declare -g "CUSTOMERS_UPDATE_customerKey=${customerKey}"

    fi

    

    CUSTOMERS_UPDATE_URL="https://www.googleapis.com/admin/directory/v1/customers/${customerKey}?key=${CLIENTID}"


    curl -s \
        --request PUT \
        ${CUSTOMERS_UPDATE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PUT \\ 
        ${CUSTOMERS_UPDATE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

domainAliases_delete() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${DOMAINALIASES_DELETE_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "DOMAINALIASES_DELETE_customer=${customer}"

    fi

    
    domainAliasNameMeta=( 
        'string'
        'Name of domain alias to be retrieved.'
    )


    if [[ -z "${DOMAINALIASES_DELETE_domainAliasName}" ]]
    then
        if ! [[ -z "${PARAM_domainAliasName}" ]]
        then 
            checkParams domainAliasName "false"
            
        else
            getParams domainAliasName
        fi
        declare -g "DOMAINALIASES_DELETE_domainAliasName=${domainAliasName}"

    fi

    

    DOMAINALIASES_DELETE_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/domainaliases/${domainAliasName}?key=${CLIENTID}"


    curl -s \
        --request DELETE \
        ${DOMAINALIASES_DELETE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request DELETE \\ 
        ${DOMAINALIASES_DELETE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

domainAliases_get() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${DOMAINALIASES_GET_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "DOMAINALIASES_GET_customer=${customer}"

    fi

    
    domainAliasNameMeta=( 
        'string'
        'Name of domain alias to be retrieved.'
    )


    if [[ -z "${DOMAINALIASES_GET_domainAliasName}" ]]
    then
        if ! [[ -z "${PARAM_domainAliasName}" ]]
        then 
            checkParams domainAliasName "false"
            
        else
            getParams domainAliasName
        fi
        declare -g "DOMAINALIASES_GET_domainAliasName=${domainAliasName}"

    fi

    

    DOMAINALIASES_GET_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/domainaliases/${domainAliasName}?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${DOMAINALIASES_GET_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${DOMAINALIASES_GET_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

domainAliases_insert() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${DOMAINALIASES_INSERT_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "DOMAINALIASES_INSERT_customer=${customer}"

    fi

    

    DOMAINALIASES_INSERT_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/domainaliases?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${DOMAINALIASES_INSERT_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${DOMAINALIASES_INSERT_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

domainAliases_list() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${DOMAINALIASES_LIST_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "DOMAINALIASES_LIST_customer=${customer}"

    fi

    

    DOMAINALIASES_LIST_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/domainaliases?key=${CLIENTID}"

    inpParams=( parentDomainName )

    parentDomainNameMeta=(
        'string'
        'Name of the parent domain for which domain aliases are to be fetched.'
    )


    echo -en "# Would you like to define input parameters? [y/n] \n${inpParams}\n\n~> "
    read -r inpParChoice
    clear


    if [[ ${inpParChoice} =~ "y" ]] || [[ ${inpParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#inpParams[@]} ; i++ ))
        do

            select option in ${inpParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            DOMAINALIASES_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            DOMAINALIASES_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam

                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request GET \
        ${DOMAINALIASES_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${DOMAINALIASES_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

domains_delete() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${DOMAINS_DELETE_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "DOMAINS_DELETE_customer=${customer}"

    fi

    
    domainNameMeta=( 
        'string'
        'Name of domain to be deleted'
    )


    if [[ -z "${DOMAINS_DELETE_domainName}" ]]
    then
        if ! [[ -z "${PARAM_domainName}" ]]
        then 
            checkParams domainName "false"
            
        else
            getParams domainName
        fi
        declare -g "DOMAINS_DELETE_domainName=${domainName}"

    fi

    

    DOMAINS_DELETE_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/domains/${domainName}?key=${CLIENTID}"


    curl -s \
        --request DELETE \
        ${DOMAINS_DELETE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request DELETE \\ 
        ${DOMAINS_DELETE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

domains_get() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${DOMAINS_GET_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "DOMAINS_GET_customer=${customer}"

    fi

    
    domainNameMeta=( 
        'string'
        'Name of domain to be retrieved'
    )


    if [[ -z "${DOMAINS_GET_domainName}" ]]
    then
        if ! [[ -z "${PARAM_domainName}" ]]
        then 
            checkParams domainName "false"
            
        else
            getParams domainName
        fi
        declare -g "DOMAINS_GET_domainName=${domainName}"

    fi

    

    DOMAINS_GET_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/domains/${domainName}?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${DOMAINS_GET_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${DOMAINS_GET_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

domains_insert() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${DOMAINS_INSERT_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "DOMAINS_INSERT_customer=${customer}"

    fi

    

    DOMAINS_INSERT_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/domains?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${DOMAINS_INSERT_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${DOMAINS_INSERT_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

domains_list() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${DOMAINS_LIST_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "DOMAINS_LIST_customer=${customer}"

    fi

    

    DOMAINS_LIST_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/domains?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${DOMAINS_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${DOMAINS_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

groups_delete() {


    groupKeyMeta=( 
        'string'
        'Email or immutable ID of the group'
    )


    if [[ -z "${GROUPS_DELETE_groupKey}" ]]
    then
        if ! [[ -z "${PARAM_groupKey}" ]]
        then 
            checkParams groupKey "false"
            
        else
            getParams groupKey
        fi
        declare -g "GROUPS_DELETE_groupKey=${groupKey}"

    fi

    

    GROUPS_DELETE_URL="https://www.googleapis.com/admin/directory/v1/groups/${groupKey}?key=${CLIENTID}"


    curl -s \
        --request DELETE \
        ${GROUPS_DELETE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request DELETE \\ 
        ${GROUPS_DELETE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

groups_get() {


    groupKeyMeta=( 
        'string'
        'Email or immutable ID of the group'
    )


    if [[ -z "${GROUPS_GET_groupKey}" ]]
    then
        if ! [[ -z "${PARAM_groupKey}" ]]
        then 
            checkParams groupKey "false"
            
        else
            getParams groupKey
        fi
        declare -g "GROUPS_GET_groupKey=${groupKey}"

    fi

    

    GROUPS_GET_URL="https://www.googleapis.com/admin/directory/v1/groups/${groupKey}?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${GROUPS_GET_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${GROUPS_GET_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

groups_insert() {



    GROUPS_INSERT_URL="https://www.googleapis.com/admin/directory/v1/groups?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${GROUPS_INSERT_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${GROUPS_INSERT_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

groups_list() {



    GROUPS_LIST_URL="https://www.googleapis.com/admin/directory/v1/groups?key=${CLIENTID}"

    optParams=( orderBy sortOrder )

    orderByMeta=(
        'string'
        'Column to use for sorting results'
        '["orderByUndefined","email"]'
    )

    sortOrderMeta=(
        'string'
        'Whether to return results in ascending or descending order. Only of use when orderBy is also used'
        '["SORT_ORDER_UNDEFINED","ASCENDING","DESCENDING"]'
    )


    echo -en "# Would you like to define extra parameters? [y/n] \n${optParams}\n\n~> "
    read -r optParChoice
    clear


    if [[ ${optParChoice} =~ "y" ]] || [[ ${optParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#optParams[@]} ; i++ ))
        do

            select option in ${optParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            GROUPS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            GROUPS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam
                        
                        break
                    fi
                fi
            done
        done
    fi
    inpParams=( customer domain maxResults pageToken query userKey )

    customerMeta=(
        'string'
        'Immutable ID of the G Suite account. In case of multi-domain, to fetch all groups for a customer, fill this field instead of domain.'
    )

    domainMeta=(
        'string'
        'Name of the domain. Fill this field to get groups from only this domain. To return all groups in a multi-domain fill customer field instead.'
    )

    maxResultsMeta=(
        'integer'
        'Maximum number of results to return. Max allowed value is 200.'
    )

    pageTokenMeta=(
        'string'
        'Token to specify next page in the list'
    )

    queryMeta=(
        'string'
        'Query string search. Should be of the form "". Complete documentation is at https: //developers.google.com/admin-sdk/directory/v1/guides/search-groups'
    )

    userKeyMeta=(
        'string'
        'Email or immutable ID of the user if only those groups are to be listed, the given user is a member of. If it'\''s an ID, it should match with the ID of the user object.'
    )


    echo -en "# Would you like to define input parameters? [y/n] \n${inpParams}\n\n~> "
    read -r inpParChoice
    clear


    if [[ ${inpParChoice} =~ "y" ]] || [[ ${inpParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#inpParams[@]} ; i++ ))
        do

            select option in ${inpParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            GROUPS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            GROUPS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam

                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request GET \
        ${GROUPS_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${GROUPS_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

groups_patch() {


    groupKeyMeta=( 
        'string'
        'Email or immutable ID of the group. If ID, it should match with id of group object'
    )


    if [[ -z "${GROUPS_PATCH_groupKey}" ]]
    then
        if ! [[ -z "${PARAM_groupKey}" ]]
        then 
            checkParams groupKey "false"
            
        else
            getParams groupKey
        fi
        declare -g "GROUPS_PATCH_groupKey=${groupKey}"

    fi

    

    GROUPS_PATCH_URL="https://www.googleapis.com/admin/directory/v1/groups/${groupKey}?key=${CLIENTID}"


    curl -s \
        --request PATCH \
        ${GROUPS_PATCH_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PATCH \\ 
        ${GROUPS_PATCH_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

groups_update() {


    groupKeyMeta=( 
        'string'
        'Email or immutable ID of the group. If ID, it should match with id of group object'
    )


    if [[ -z "${GROUPS_UPDATE_groupKey}" ]]
    then
        if ! [[ -z "${PARAM_groupKey}" ]]
        then 
            checkParams groupKey "false"
            
        else
            getParams groupKey
        fi
        declare -g "GROUPS_UPDATE_groupKey=${groupKey}"

    fi

    

    GROUPS_UPDATE_URL="https://www.googleapis.com/admin/directory/v1/groups/${groupKey}?key=${CLIENTID}"


    curl -s \
        --request PUT \
        ${GROUPS_UPDATE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PUT \\ 
        ${GROUPS_UPDATE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

members_delete() {


    groupKeyMeta=( 
        'string'
        'Email or immutable ID of the group'
    )


    if [[ -z "${MEMBERS_DELETE_groupKey}" ]]
    then
        if ! [[ -z "${PARAM_groupKey}" ]]
        then 
            checkParams groupKey "false"
            
        else
            getParams groupKey
        fi
        declare -g "MEMBERS_DELETE_groupKey=${groupKey}"

    fi

    
    memberKeyMeta=( 
        'string'
        'Email or immutable ID of the member'
    )


    if [[ -z "${MEMBERS_DELETE_memberKey}" ]]
    then
        if ! [[ -z "${PARAM_memberKey}" ]]
        then 
            checkParams memberKey "false"
            
        else
            getParams memberKey
        fi
        declare -g "MEMBERS_DELETE_memberKey=${memberKey}"

    fi

    

    MEMBERS_DELETE_URL="https://www.googleapis.com/admin/directory/v1/groups/${groupKey}/members/${memberKey}?key=${CLIENTID}"


    curl -s \
        --request DELETE \
        ${MEMBERS_DELETE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request DELETE \\ 
        ${MEMBERS_DELETE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

members_get() {


    groupKeyMeta=( 
        'string'
        'Email or immutable ID of the group'
    )


    if [[ -z "${MEMBERS_GET_groupKey}" ]]
    then
        if ! [[ -z "${PARAM_groupKey}" ]]
        then 
            checkParams groupKey "false"
            
        else
            getParams groupKey
        fi
        declare -g "MEMBERS_GET_groupKey=${groupKey}"

    fi

    
    memberKeyMeta=( 
        'string'
        'Email or immutable ID of the member'
    )


    if [[ -z "${MEMBERS_GET_memberKey}" ]]
    then
        if ! [[ -z "${PARAM_memberKey}" ]]
        then 
            checkParams memberKey "false"
            
        else
            getParams memberKey
        fi
        declare -g "MEMBERS_GET_memberKey=${memberKey}"

    fi

    

    MEMBERS_GET_URL="https://www.googleapis.com/admin/directory/v1/groups/${groupKey}/members/${memberKey}?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${MEMBERS_GET_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${MEMBERS_GET_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

members_hasMember() {


    groupKeyMeta=( 
        'string'
        'Identifies the group in the API request. The value can be the group'\''s email address, group alias, or the unique group ID.'
    )


    if [[ -z "${MEMBERS_HASMEMBER_groupKey}" ]]
    then
        if ! [[ -z "${PARAM_groupKey}" ]]
        then 
            checkParams groupKey "false"
            
        else
            getParams groupKey
        fi
        declare -g "MEMBERS_HASMEMBER_groupKey=${groupKey}"

    fi

    
    memberKeyMeta=( 
        'string'
        'Identifies the user member in the API request. The value can be the user'\''s primary email address, alias, or unique ID.'
    )


    if [[ -z "${MEMBERS_HASMEMBER_memberKey}" ]]
    then
        if ! [[ -z "${PARAM_memberKey}" ]]
        then 
            checkParams memberKey "false"
            
        else
            getParams memberKey
        fi
        declare -g "MEMBERS_HASMEMBER_memberKey=${memberKey}"

    fi

    

    MEMBERS_HASMEMBER_URL="https://www.googleapis.com/admin/directory/v1/groups/${groupKey}/hasMember/${memberKey}?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${MEMBERS_HASMEMBER_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${MEMBERS_HASMEMBER_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

members_insert() {


    groupKeyMeta=( 
        'string'
        'Email or immutable ID of the group'
    )


    if [[ -z "${MEMBERS_INSERT_groupKey}" ]]
    then
        if ! [[ -z "${PARAM_groupKey}" ]]
        then 
            checkParams groupKey "false"
            
        else
            getParams groupKey
        fi
        declare -g "MEMBERS_INSERT_groupKey=${groupKey}"

    fi

    

    MEMBERS_INSERT_URL="https://www.googleapis.com/admin/directory/v1/groups/${groupKey}/members?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${MEMBERS_INSERT_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${MEMBERS_INSERT_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

members_list() {


    groupKeyMeta=( 
        'string'
        'Email or immutable ID of the group'
    )


    if [[ -z "${MEMBERS_LIST_groupKey}" ]]
    then
        if ! [[ -z "${PARAM_groupKey}" ]]
        then 
            checkParams groupKey "false"
            
        else
            getParams groupKey
        fi
        declare -g "MEMBERS_LIST_groupKey=${groupKey}"

    fi

    

    MEMBERS_LIST_URL="https://www.googleapis.com/admin/directory/v1/groups/${groupKey}/members?key=${CLIENTID}"

    inpParams=( includeDerivedMembership maxResults pageToken roles )

    includeDerivedMembershipMeta=(
        'boolean'
        'Whether to list indirect memberships. Default: false.'
    )

    maxResultsMeta=(
        'integer'
        'Maximum number of results to return. Max allowed value is 200.'
    )

    pageTokenMeta=(
        'string'
        'Token to specify next page in the list'
    )

    rolesMeta=(
        'string'
        'Comma separated role values to filter list results on.'
    )


    echo -en "# Would you like to define input parameters? [y/n] \n${inpParams}\n\n~> "
    read -r inpParChoice
    clear


    if [[ ${inpParChoice} =~ "y" ]] || [[ ${inpParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#inpParams[@]} ; i++ ))
        do

            select option in ${inpParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            MEMBERS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            MEMBERS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam

                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request GET \
        ${MEMBERS_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${MEMBERS_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

members_patch() {


    groupKeyMeta=( 
        'string'
        'Email or immutable ID of the group. If ID, it should match with id of group object'
    )


    if [[ -z "${MEMBERS_PATCH_groupKey}" ]]
    then
        if ! [[ -z "${PARAM_groupKey}" ]]
        then 
            checkParams groupKey "false"
            
        else
            getParams groupKey
        fi
        declare -g "MEMBERS_PATCH_groupKey=${groupKey}"

    fi

    
    memberKeyMeta=( 
        'string'
        'Email or immutable ID of the user. If ID, it should match with id of member object'
    )


    if [[ -z "${MEMBERS_PATCH_memberKey}" ]]
    then
        if ! [[ -z "${PARAM_memberKey}" ]]
        then 
            checkParams memberKey "false"
            
        else
            getParams memberKey
        fi
        declare -g "MEMBERS_PATCH_memberKey=${memberKey}"

    fi

    

    MEMBERS_PATCH_URL="https://www.googleapis.com/admin/directory/v1/groups/${groupKey}/members/${memberKey}?key=${CLIENTID}"


    curl -s \
        --request PATCH \
        ${MEMBERS_PATCH_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PATCH \\ 
        ${MEMBERS_PATCH_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

members_update() {


    groupKeyMeta=( 
        'string'
        'Email or immutable ID of the group. If ID, it should match with id of group object'
    )


    if [[ -z "${MEMBERS_UPDATE_groupKey}" ]]
    then
        if ! [[ -z "${PARAM_groupKey}" ]]
        then 
            checkParams groupKey "false"
            
        else
            getParams groupKey
        fi
        declare -g "MEMBERS_UPDATE_groupKey=${groupKey}"

    fi

    
    memberKeyMeta=( 
        'string'
        'Email or immutable ID of the user. If ID, it should match with id of member object'
    )


    if [[ -z "${MEMBERS_UPDATE_memberKey}" ]]
    then
        if ! [[ -z "${PARAM_memberKey}" ]]
        then 
            checkParams memberKey "false"
            
        else
            getParams memberKey
        fi
        declare -g "MEMBERS_UPDATE_memberKey=${memberKey}"

    fi

    

    MEMBERS_UPDATE_URL="https://www.googleapis.com/admin/directory/v1/groups/${groupKey}/members/${memberKey}?key=${CLIENTID}"


    curl -s \
        --request PUT \
        ${MEMBERS_UPDATE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PUT \\ 
        ${MEMBERS_UPDATE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

mobiledevices_action() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${MOBILEDEVICES_ACTION_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "MOBILEDEVICES_ACTION_customerId=${customerId}"

    fi

    
    resourceIdMeta=( 
        'string'
        'Immutable ID of Mobile Device'
    )


    if [[ -z "${MOBILEDEVICES_ACTION_resourceId}" ]]
    then
        if ! [[ -z "${PARAM_resourceId}" ]]
        then 
            checkParams resourceId "false"
            
        else
            getParams resourceId
        fi
        declare -g "MOBILEDEVICES_ACTION_resourceId=${resourceId}"

    fi

    

    MOBILEDEVICES_ACTION_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/devices/mobile/${resourceId}/action?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${MOBILEDEVICES_ACTION_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${MOBILEDEVICES_ACTION_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

mobiledevices_delete() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${MOBILEDEVICES_DELETE_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "MOBILEDEVICES_DELETE_customerId=${customerId}"

    fi

    
    resourceIdMeta=( 
        'string'
        'Immutable ID of Mobile Device'
    )


    if [[ -z "${MOBILEDEVICES_DELETE_resourceId}" ]]
    then
        if ! [[ -z "${PARAM_resourceId}" ]]
        then 
            checkParams resourceId "false"
            
        else
            getParams resourceId
        fi
        declare -g "MOBILEDEVICES_DELETE_resourceId=${resourceId}"

    fi

    

    MOBILEDEVICES_DELETE_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/devices/mobile/${resourceId}?key=${CLIENTID}"


    curl -s \
        --request DELETE \
        ${MOBILEDEVICES_DELETE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request DELETE \\ 
        ${MOBILEDEVICES_DELETE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

mobiledevices_get() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${MOBILEDEVICES_GET_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "MOBILEDEVICES_GET_customerId=${customerId}"

    fi

    
    resourceIdMeta=( 
        'string'
        'Immutable ID of Mobile Device'
    )


    if [[ -z "${MOBILEDEVICES_GET_resourceId}" ]]
    then
        if ! [[ -z "${PARAM_resourceId}" ]]
        then 
            checkParams resourceId "false"
            
        else
            getParams resourceId
        fi
        declare -g "MOBILEDEVICES_GET_resourceId=${resourceId}"

    fi

    

    MOBILEDEVICES_GET_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/devices/mobile/${resourceId}?key=${CLIENTID}"

    optParams=( projection )

    projectionMeta=(
        'string'
        'Restrict information returned to a set of selected fields.'
        '["PROJECTION_UNDEFINED","BASIC","FULL"]'
    )


    echo -en "# Would you like to define extra parameters? [y/n] \n${optParams}\n\n~> "
    read -r optParChoice
    clear


    if [[ ${optParChoice} =~ "y" ]] || [[ ${optParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#optParams[@]} ; i++ ))
        do

            select option in ${optParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            MOBILEDEVICES_GET_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            MOBILEDEVICES_GET_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam
                        
                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request GET \
        ${MOBILEDEVICES_GET_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${MOBILEDEVICES_GET_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

mobiledevices_list() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${MOBILEDEVICES_LIST_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "MOBILEDEVICES_LIST_customerId=${customerId}"

    fi

    

    MOBILEDEVICES_LIST_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/devices/mobile?key=${CLIENTID}"

    optParams=( orderBy projection sortOrder )

    orderByMeta=(
        'string'
        'Column to use for sorting results'
        '["orderByUndefined","deviceId","email","lastSync","model","name","os","status","type"]'
    )

    projectionMeta=(
        'string'
        'Restrict information returned to a set of selected fields.'
        '["PROJECTION_UNDEFINED","BASIC","FULL"]'
    )

    sortOrderMeta=(
        'string'
        'Whether to return results in ascending or descending order. Only of use when orderBy is also used'
        '["SORT_ORDER_UNDEFINED","ASCENDING","DESCENDING"]'
    )


    echo -en "# Would you like to define extra parameters? [y/n] \n${optParams}\n\n~> "
    read -r optParChoice
    clear


    if [[ ${optParChoice} =~ "y" ]] || [[ ${optParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#optParams[@]} ; i++ ))
        do

            select option in ${optParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            MOBILEDEVICES_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            MOBILEDEVICES_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam
                        
                        break
                    fi
                fi
            done
        done
    fi
    inpParams=( maxResults pageToken query )

    maxResultsMeta=(
        'integer'
        'Maximum number of results to return. Max allowed value is 100.'
    )

    pageTokenMeta=(
        'string'
        'Token to specify next page in the list'
    )

    queryMeta=(
        'string'
        'Search string in the format given at http://support.google.com/a/bin/answer.py?answer=1408863#search'
    )


    echo -en "# Would you like to define input parameters? [y/n] \n${inpParams}\n\n~> "
    read -r inpParChoice
    clear


    if [[ ${inpParChoice} =~ "y" ]] || [[ ${inpParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#inpParams[@]} ; i++ ))
        do

            select option in ${inpParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            MOBILEDEVICES_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            MOBILEDEVICES_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam

                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request GET \
        ${MOBILEDEVICES_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${MOBILEDEVICES_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

orgunits_delete() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${ORGUNITS_DELETE_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "ORGUNITS_DELETE_customerId=${customerId}"

    fi

    
    orgUnitPathMeta=( 
        'string'
        'Full path of the organizational unit or its ID'
    )


    if [[ -z "${ORGUNITS_DELETE_orgUnitPath}" ]]
    then
        if ! [[ -z "${PARAM_orgUnitPath}" ]]
        then 
            checkParams orgUnitPath "false"
            
        else
            getParams orgUnitPath
        fi
        declare -g "ORGUNITS_DELETE_orgUnitPath=${orgUnitPath}"

    fi

    

    ORGUNITS_DELETE_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/orgunits/${orgunitsId}?key=${CLIENTID}"


    curl -s \
        --request DELETE \
        ${ORGUNITS_DELETE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request DELETE \\ 
        ${ORGUNITS_DELETE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

orgunits_get() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${ORGUNITS_GET_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "ORGUNITS_GET_customerId=${customerId}"

    fi

    
    orgUnitPathMeta=( 
        'string'
        'Full path of the organizational unit or its ID'
    )


    if [[ -z "${ORGUNITS_GET_orgUnitPath}" ]]
    then
        if ! [[ -z "${PARAM_orgUnitPath}" ]]
        then 
            checkParams orgUnitPath "false"
            
        else
            getParams orgUnitPath
        fi
        declare -g "ORGUNITS_GET_orgUnitPath=${orgUnitPath}"

    fi

    

    ORGUNITS_GET_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/orgunits/${orgunitsId}?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${ORGUNITS_GET_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${ORGUNITS_GET_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

orgunits_insert() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${ORGUNITS_INSERT_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "ORGUNITS_INSERT_customerId=${customerId}"

    fi

    

    ORGUNITS_INSERT_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/orgunits?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${ORGUNITS_INSERT_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${ORGUNITS_INSERT_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

orgunits_list() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${ORGUNITS_LIST_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "ORGUNITS_LIST_customerId=${customerId}"

    fi

    

    ORGUNITS_LIST_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/orgunits?key=${CLIENTID}"

    optParams=( type )

    typeMeta=(
        'string'
        'Whether to return all sub-organizations or just immediate children'
        '["typeUndefined","all","children"]'
    )


    echo -en "# Would you like to define extra parameters? [y/n] \n${optParams}\n\n~> "
    read -r optParChoice
    clear


    if [[ ${optParChoice} =~ "y" ]] || [[ ${optParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#optParams[@]} ; i++ ))
        do

            select option in ${optParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            ORGUNITS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            ORGUNITS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam
                        
                        break
                    fi
                fi
            done
        done
    fi
    inpParams=( orgUnitPath )

    orgUnitPathMeta=(
        'string'
        'the URL-encoded organizational unit'\''s path or its ID'
    )


    echo -en "# Would you like to define input parameters? [y/n] \n${inpParams}\n\n~> "
    read -r inpParChoice
    clear


    if [[ ${inpParChoice} =~ "y" ]] || [[ ${inpParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#inpParams[@]} ; i++ ))
        do

            select option in ${inpParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            ORGUNITS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            ORGUNITS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam

                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request GET \
        ${ORGUNITS_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${ORGUNITS_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

orgunits_patch() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${ORGUNITS_PATCH_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "ORGUNITS_PATCH_customerId=${customerId}"

    fi

    
    orgUnitPathMeta=( 
        'string'
        'Full path of the organizational unit or its ID'
    )


    if [[ -z "${ORGUNITS_PATCH_orgUnitPath}" ]]
    then
        if ! [[ -z "${PARAM_orgUnitPath}" ]]
        then 
            checkParams orgUnitPath "false"
            
        else
            getParams orgUnitPath
        fi
        declare -g "ORGUNITS_PATCH_orgUnitPath=${orgUnitPath}"

    fi

    

    ORGUNITS_PATCH_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/orgunits/${orgunitsId}?key=${CLIENTID}"


    curl -s \
        --request PATCH \
        ${ORGUNITS_PATCH_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PATCH \\ 
        ${ORGUNITS_PATCH_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

orgunits_update() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${ORGUNITS_UPDATE_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "ORGUNITS_UPDATE_customerId=${customerId}"

    fi

    
    orgUnitPathMeta=( 
        'string'
        'Full path of the organizational unit or its ID'
    )


    if [[ -z "${ORGUNITS_UPDATE_orgUnitPath}" ]]
    then
        if ! [[ -z "${PARAM_orgUnitPath}" ]]
        then 
            checkParams orgUnitPath "false"
            
        else
            getParams orgUnitPath
        fi
        declare -g "ORGUNITS_UPDATE_orgUnitPath=${orgUnitPath}"

    fi

    

    ORGUNITS_UPDATE_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/orgunits/${orgunitsId}?key=${CLIENTID}"


    curl -s \
        --request PUT \
        ${ORGUNITS_UPDATE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PUT \\ 
        ${ORGUNITS_UPDATE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

privileges_list() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${PRIVILEGES_LIST_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "PRIVILEGES_LIST_customer=${customer}"

    fi

    

    PRIVILEGES_LIST_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/roles/ALL/privileges?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${PRIVILEGES_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${PRIVILEGES_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

roleAssignments_delete() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${ROLEASSIGNMENTS_DELETE_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "ROLEASSIGNMENTS_DELETE_customer=${customer}"

    fi

    
    roleAssignmentIdMeta=( 
        'string'
        'Immutable ID of the role assignment.'
    )


    if [[ -z "${ROLEASSIGNMENTS_DELETE_roleAssignmentId}" ]]
    then
        if ! [[ -z "${PARAM_roleAssignmentId}" ]]
        then 
            checkParams roleAssignmentId "false"
            
        else
            getParams roleAssignmentId
        fi
        declare -g "ROLEASSIGNMENTS_DELETE_roleAssignmentId=${roleAssignmentId}"

    fi

    

    ROLEASSIGNMENTS_DELETE_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/roleassignments/${roleAssignmentId}?key=${CLIENTID}"


    curl -s \
        --request DELETE \
        ${ROLEASSIGNMENTS_DELETE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request DELETE \\ 
        ${ROLEASSIGNMENTS_DELETE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

roleAssignments_get() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${ROLEASSIGNMENTS_GET_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "ROLEASSIGNMENTS_GET_customer=${customer}"

    fi

    
    roleAssignmentIdMeta=( 
        'string'
        'Immutable ID of the role assignment.'
    )


    if [[ -z "${ROLEASSIGNMENTS_GET_roleAssignmentId}" ]]
    then
        if ! [[ -z "${PARAM_roleAssignmentId}" ]]
        then 
            checkParams roleAssignmentId "false"
            
        else
            getParams roleAssignmentId
        fi
        declare -g "ROLEASSIGNMENTS_GET_roleAssignmentId=${roleAssignmentId}"

    fi

    

    ROLEASSIGNMENTS_GET_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/roleassignments/${roleAssignmentId}?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${ROLEASSIGNMENTS_GET_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${ROLEASSIGNMENTS_GET_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

roleAssignments_insert() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${ROLEASSIGNMENTS_INSERT_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "ROLEASSIGNMENTS_INSERT_customer=${customer}"

    fi

    

    ROLEASSIGNMENTS_INSERT_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/roleassignments?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${ROLEASSIGNMENTS_INSERT_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${ROLEASSIGNMENTS_INSERT_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

roleAssignments_list() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${ROLEASSIGNMENTS_LIST_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "ROLEASSIGNMENTS_LIST_customer=${customer}"

    fi

    

    ROLEASSIGNMENTS_LIST_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/roleassignments?key=${CLIENTID}"

    inpParams=( maxResults pageToken roleId userKey )

    maxResultsMeta=(
        'integer'
        'Maximum number of results to return.'
    )

    pageTokenMeta=(
        'string'
        'Token to specify the next page in the list.'
    )

    roleIdMeta=(
        'string'
        'Immutable ID of a role. If included in the request, returns only role assignments containing this role ID.'
    )

    userKeyMeta=(
        'string'
        'The user'\''s primary email address, alias email address, or unique user ID. If included in the request, returns role assignments only for this user.'
    )


    echo -en "# Would you like to define input parameters? [y/n] \n${inpParams}\n\n~> "
    read -r inpParChoice
    clear


    if [[ ${inpParChoice} =~ "y" ]] || [[ ${inpParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#inpParams[@]} ; i++ ))
        do

            select option in ${inpParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            ROLEASSIGNMENTS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            ROLEASSIGNMENTS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam

                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request GET \
        ${ROLEASSIGNMENTS_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${ROLEASSIGNMENTS_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

roles_delete() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${ROLES_DELETE_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "ROLES_DELETE_customer=${customer}"

    fi

    
    roleIdMeta=( 
        'string'
        'Immutable ID of the role.'
    )


    if [[ -z "${ROLES_DELETE_roleId}" ]]
    then
        if ! [[ -z "${PARAM_roleId}" ]]
        then 
            checkParams roleId "false"
            
        else
            getParams roleId
        fi
        declare -g "ROLES_DELETE_roleId=${roleId}"

    fi

    

    ROLES_DELETE_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/roles/${roleId}?key=${CLIENTID}"


    curl -s \
        --request DELETE \
        ${ROLES_DELETE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request DELETE \\ 
        ${ROLES_DELETE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

roles_get() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${ROLES_GET_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "ROLES_GET_customer=${customer}"

    fi

    
    roleIdMeta=( 
        'string'
        'Immutable ID of the role.'
    )


    if [[ -z "${ROLES_GET_roleId}" ]]
    then
        if ! [[ -z "${PARAM_roleId}" ]]
        then 
            checkParams roleId "false"
            
        else
            getParams roleId
        fi
        declare -g "ROLES_GET_roleId=${roleId}"

    fi

    

    ROLES_GET_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/roles/${roleId}?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${ROLES_GET_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${ROLES_GET_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

roles_insert() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${ROLES_INSERT_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "ROLES_INSERT_customer=${customer}"

    fi

    

    ROLES_INSERT_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/roles?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${ROLES_INSERT_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${ROLES_INSERT_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

roles_list() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${ROLES_LIST_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "ROLES_LIST_customer=${customer}"

    fi

    

    ROLES_LIST_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/roles?key=${CLIENTID}"

    inpParams=( maxResults pageToken )

    maxResultsMeta=(
        'integer'
        'Maximum number of results to return.'
    )

    pageTokenMeta=(
        'string'
        'Token to specify the next page in the list.'
    )


    echo -en "# Would you like to define input parameters? [y/n] \n${inpParams}\n\n~> "
    read -r inpParChoice
    clear


    if [[ ${inpParChoice} =~ "y" ]] || [[ ${inpParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#inpParams[@]} ; i++ ))
        do

            select option in ${inpParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            ROLES_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            ROLES_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam

                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request GET \
        ${ROLES_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${ROLES_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

roles_patch() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${ROLES_PATCH_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "ROLES_PATCH_customer=${customer}"

    fi

    
    roleIdMeta=( 
        'string'
        'Immutable ID of the role.'
    )


    if [[ -z "${ROLES_PATCH_roleId}" ]]
    then
        if ! [[ -z "${PARAM_roleId}" ]]
        then 
            checkParams roleId "false"
            
        else
            getParams roleId
        fi
        declare -g "ROLES_PATCH_roleId=${roleId}"

    fi

    

    ROLES_PATCH_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/roles/${roleId}?key=${CLIENTID}"


    curl -s \
        --request PATCH \
        ${ROLES_PATCH_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PATCH \\ 
        ${ROLES_PATCH_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

roles_update() {


    customerMeta=( 
        'string'
        'Immutable ID of the G Suite account.'
    )


    if [[ -z "${ROLES_UPDATE_customer}" ]]
    then
        if ! [[ -z "${PARAM_customer}" ]]
        then 
            checkParams customer "false"
            
        else
            getParams customer
        fi
        declare -g "ROLES_UPDATE_customer=${customer}"

    fi

    
    roleIdMeta=( 
        'string'
        'Immutable ID of the role.'
    )


    if [[ -z "${ROLES_UPDATE_roleId}" ]]
    then
        if ! [[ -z "${PARAM_roleId}" ]]
        then 
            checkParams roleId "false"
            
        else
            getParams roleId
        fi
        declare -g "ROLES_UPDATE_roleId=${roleId}"

    fi

    

    ROLES_UPDATE_URL="https://www.googleapis.com/admin/directory/v1/customer/${customer}/roles/${roleId}?key=${CLIENTID}"


    curl -s \
        --request PUT \
        ${ROLES_UPDATE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PUT \\ 
        ${ROLES_UPDATE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

schemas_delete() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${SCHEMAS_DELETE_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "SCHEMAS_DELETE_customerId=${customerId}"

    fi

    
    schemaKeyMeta=( 
        'string'
        'Name or immutable ID of the schema'
    )


    if [[ -z "${SCHEMAS_DELETE_schemaKey}" ]]
    then
        if ! [[ -z "${PARAM_schemaKey}" ]]
        then 
            checkParams schemaKey "false"
            
        else
            getParams schemaKey
        fi
        declare -g "SCHEMAS_DELETE_schemaKey=${schemaKey}"

    fi

    

    SCHEMAS_DELETE_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/schemas/${schemaKey}?key=${CLIENTID}"


    curl -s \
        --request DELETE \
        ${SCHEMAS_DELETE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request DELETE \\ 
        ${SCHEMAS_DELETE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

schemas_get() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${SCHEMAS_GET_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "SCHEMAS_GET_customerId=${customerId}"

    fi

    
    schemaKeyMeta=( 
        'string'
        'Name or immutable ID of the schema'
    )


    if [[ -z "${SCHEMAS_GET_schemaKey}" ]]
    then
        if ! [[ -z "${PARAM_schemaKey}" ]]
        then 
            checkParams schemaKey "false"
            
        else
            getParams schemaKey
        fi
        declare -g "SCHEMAS_GET_schemaKey=${schemaKey}"

    fi

    

    SCHEMAS_GET_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/schemas/${schemaKey}?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${SCHEMAS_GET_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${SCHEMAS_GET_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

schemas_insert() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${SCHEMAS_INSERT_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "SCHEMAS_INSERT_customerId=${customerId}"

    fi

    

    SCHEMAS_INSERT_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/schemas?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${SCHEMAS_INSERT_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${SCHEMAS_INSERT_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

schemas_list() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${SCHEMAS_LIST_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "SCHEMAS_LIST_customerId=${customerId}"

    fi

    

    SCHEMAS_LIST_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/schemas?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${SCHEMAS_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${SCHEMAS_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

schemas_patch() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${SCHEMAS_PATCH_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "SCHEMAS_PATCH_customerId=${customerId}"

    fi

    
    schemaKeyMeta=( 
        'string'
        'Name or immutable ID of the schema.'
    )


    if [[ -z "${SCHEMAS_PATCH_schemaKey}" ]]
    then
        if ! [[ -z "${PARAM_schemaKey}" ]]
        then 
            checkParams schemaKey "false"
            
        else
            getParams schemaKey
        fi
        declare -g "SCHEMAS_PATCH_schemaKey=${schemaKey}"

    fi

    

    SCHEMAS_PATCH_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/schemas/${schemaKey}?key=${CLIENTID}"


    curl -s \
        --request PATCH \
        ${SCHEMAS_PATCH_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PATCH \\ 
        ${SCHEMAS_PATCH_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

schemas_update() {


    customerIdMeta=( 
        'string'
        'Immutable ID of the G Suite account'
    )


    if [[ -z "${SCHEMAS_UPDATE_customerId}" ]]
    then
        if ! [[ -z "${PARAM_customerId}" ]]
        then 
            checkParams customerId "false"
            
        else
            getParams customerId
        fi
        declare -g "SCHEMAS_UPDATE_customerId=${customerId}"

    fi

    
    schemaKeyMeta=( 
        'string'
        'Name or immutable ID of the schema.'
    )


    if [[ -z "${SCHEMAS_UPDATE_schemaKey}" ]]
    then
        if ! [[ -z "${PARAM_schemaKey}" ]]
        then 
            checkParams schemaKey "false"
            
        else
            getParams schemaKey
        fi
        declare -g "SCHEMAS_UPDATE_schemaKey=${schemaKey}"

    fi

    

    SCHEMAS_UPDATE_URL="https://www.googleapis.com/admin/directory/v1/customer/${customerId}/schemas/${schemaKey}?key=${CLIENTID}"


    curl -s \
        --request PUT \
        ${SCHEMAS_UPDATE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PUT \\ 
        ${SCHEMAS_UPDATE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

tokens_delete() {


    clientIdMeta=( 
        'string'
        'The Client ID of the application the token is issued to.'
    )


    if [[ -z "${TOKENS_DELETE_clientId}" ]]
    then
        if ! [[ -z "${PARAM_clientId}" ]]
        then 
            checkParams clientId "false"
            
        else
            getParams clientId
        fi
        declare -g "TOKENS_DELETE_clientId=${clientId}"

    fi

    
    userKeyMeta=( 
        'string'
        'Identifies the user in the API request. The value can be the user'\''s primary email address, alias email address, or unique user ID.'
    )


    if [[ -z "${TOKENS_DELETE_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "TOKENS_DELETE_userKey=${userKey}"

    fi

    

    TOKENS_DELETE_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}/tokens/${clientId}?key=${CLIENTID}"


    curl -s \
        --request DELETE \
        ${TOKENS_DELETE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request DELETE \\ 
        ${TOKENS_DELETE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

tokens_get() {


    clientIdMeta=( 
        'string'
        'The Client ID of the application the token is issued to.'
    )


    if [[ -z "${TOKENS_GET_clientId}" ]]
    then
        if ! [[ -z "${PARAM_clientId}" ]]
        then 
            checkParams clientId "false"
            
        else
            getParams clientId
        fi
        declare -g "TOKENS_GET_clientId=${clientId}"

    fi

    
    userKeyMeta=( 
        'string'
        'Identifies the user in the API request. The value can be the user'\''s primary email address, alias email address, or unique user ID.'
    )


    if [[ -z "${TOKENS_GET_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "TOKENS_GET_userKey=${userKey}"

    fi

    

    TOKENS_GET_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}/tokens/${clientId}?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${TOKENS_GET_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${TOKENS_GET_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

tokens_list() {


    userKeyMeta=( 
        'string'
        'Identifies the user in the API request. The value can be the user'\''s primary email address, alias email address, or unique user ID.'
    )


    if [[ -z "${TOKENS_LIST_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "TOKENS_LIST_userKey=${userKey}"

    fi

    

    TOKENS_LIST_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}/tokens?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${TOKENS_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${TOKENS_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

twoStepVerification_turnOff() {


    userKeyMeta=( 
        'string'
        'Identifies the user in the API request. The value can be the user'\''s primary email address, alias email address, or unique user ID.'
    )


    if [[ -z "${TWOSTEPVERIFICATION_TURNOFF_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "TWOSTEPVERIFICATION_TURNOFF_userKey=${userKey}"

    fi

    

    TWOSTEPVERIFICATION_TURNOFF_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}/twoStepVerification/turnOff?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${TWOSTEPVERIFICATION_TURNOFF_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${TWOSTEPVERIFICATION_TURNOFF_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

users_delete() {


    userKeyMeta=( 
        'string'
        'Email or immutable ID of the user'
    )


    if [[ -z "${USERS_DELETE_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "USERS_DELETE_userKey=${userKey}"

    fi

    

    USERS_DELETE_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}?key=${CLIENTID}"


    curl -s \
        --request DELETE \
        ${USERS_DELETE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request DELETE \\ 
        ${USERS_DELETE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

users_get() {


    userKeyMeta=( 
        'string'
        'Email or immutable ID of the user'
    )


    if [[ -z "${USERS_GET_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "USERS_GET_userKey=${userKey}"

    fi

    

    USERS_GET_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}?key=${CLIENTID}"

    optParams=( projection viewType )

    projectionMeta=(
        'string'
        'What subset of fields to fetch for this user.'
        '["projectionUndefined","basic","custom","full"]'
    )

    viewTypeMeta=(
        'string'
        'Whether to fetch the ADMIN_VIEW or DOMAIN_PUBLIC view of the user.'
        '["view_type_undefined","admin_view","domain_public"]'
    )


    echo -en "# Would you like to define extra parameters? [y/n] \n${optParams}\n\n~> "
    read -r optParChoice
    clear


    if [[ ${optParChoice} =~ "y" ]] || [[ ${optParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#optParams[@]} ; i++ ))
        do

            select option in ${optParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            USERS_GET_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            USERS_GET_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam
                        
                        break
                    fi
                fi
            done
        done
    fi
    inpParams=( customFieldMask )

    customFieldMaskMeta=(
        'string'
        'Comma-separated list of schema names. All fields from these schemas are fetched. This should only be set when projection=custom.'
    )


    echo -en "# Would you like to define input parameters? [y/n] \n${inpParams}\n\n~> "
    read -r inpParChoice
    clear


    if [[ ${inpParChoice} =~ "y" ]] || [[ ${inpParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#inpParams[@]} ; i++ ))
        do

            select option in ${inpParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            USERS_GET_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            USERS_GET_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam

                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request GET \
        ${USERS_GET_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${USERS_GET_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

users_insert() {



    USERS_INSERT_URL="https://www.googleapis.com/admin/directory/v1/users?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${USERS_INSERT_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${USERS_INSERT_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

users_list() {



    USERS_LIST_URL="https://www.googleapis.com/admin/directory/v1/users?key=${CLIENTID}"

    optParams=( orderBy projection sortOrder viewType )

    orderByMeta=(
        'string'
        'Column to use for sorting results'
        '["orderByUndefined","email","familyName","givenName"]'
    )

    projectionMeta=(
        'string'
        'What subset of fields to fetch for this user.'
        '["projectionUndefined","basic","custom","full"]'
    )

    sortOrderMeta=(
        'string'
        'Whether to return results in ascending or descending order.'
        '["SORT_ORDER_UNDEFINED","ASCENDING","DESCENDING"]'
    )

    viewTypeMeta=(
        'string'
        'Whether to fetch the ADMIN_VIEW or DOMAIN_PUBLIC view of the user.'
        '["view_type_undefined","admin_view","domain_public"]'
    )


    echo -en "# Would you like to define extra parameters? [y/n] \n${optParams}\n\n~> "
    read -r optParChoice
    clear


    if [[ ${optParChoice} =~ "y" ]] || [[ ${optParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#optParams[@]} ; i++ ))
        do

            select option in ${optParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            USERS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            USERS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam
                        
                        break
                    fi
                fi
            done
        done
    fi
    inpParams=( customFieldMask customer domain maxResults pageToken query showDeleted )

    customFieldMaskMeta=(
        'string'
        'Comma-separated list of schema names. All fields from these schemas are fetched. This should only be set when projection=custom.'
    )

    customerMeta=(
        'string'
        'Immutable ID of the G Suite account. In case of multi-domain, to fetch all users for a customer, fill this field instead of domain.'
    )

    domainMeta=(
        'string'
        'Name of the domain. Fill this field to get users from only this domain. To return all users in a multi-domain fill customer field instead.'
    )

    maxResultsMeta=(
        'integer'
        'Maximum number of results to return.'
    )

    pageTokenMeta=(
        'string'
        'Token to specify next page in the list'
    )

    queryMeta=(
        'string'
        'Query string search. Should be of the form "". Complete documentation is at https: //developers.google.com/admin-sdk/directory/v1/guides/search-users'
    )

    showDeletedMeta=(
        'string'
        'If set to true, retrieves the list of deleted users. (Default: false)'
    )


    echo -en "# Would you like to define input parameters? [y/n] \n${inpParams}\n\n~> "
    read -r inpParChoice
    clear


    if [[ ${inpParChoice} =~ "y" ]] || [[ ${inpParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#inpParams[@]} ; i++ ))
        do

            select option in ${inpParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            USERS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            USERS_LIST_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam

                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request GET \
        ${USERS_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${USERS_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

users_makeAdmin() {


    userKeyMeta=( 
        'string'
        'Email or immutable ID of the user as admin'
    )


    if [[ -z "${USERS_MAKEADMIN_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "USERS_MAKEADMIN_userKey=${userKey}"

    fi

    

    USERS_MAKEADMIN_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}/makeAdmin?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${USERS_MAKEADMIN_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${USERS_MAKEADMIN_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

users_patch() {


    userKeyMeta=( 
        'string'
        'Email or immutable ID of the user. If ID, it should match with id of user object'
    )


    if [[ -z "${USERS_PATCH_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "USERS_PATCH_userKey=${userKey}"

    fi

    

    USERS_PATCH_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}?key=${CLIENTID}"


    curl -s \
        --request PATCH \
        ${USERS_PATCH_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PATCH \\ 
        ${USERS_PATCH_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

users_signOut() {


    userKeyMeta=( 
        'string'
        'Identifies the target user in the API request. The value can be the user'\''s primary email address, alias email address, or unique user ID.'
    )


    if [[ -z "${USERS_SIGNOUT_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "USERS_SIGNOUT_userKey=${userKey}"

    fi

    

    USERS_SIGNOUT_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}/signOut?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${USERS_SIGNOUT_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${USERS_SIGNOUT_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

users_undelete() {


    userKeyMeta=( 
        'string'
        'The immutable id of the user'
    )


    if [[ -z "${USERS_UNDELETE_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "USERS_UNDELETE_userKey=${userKey}"

    fi

    

    USERS_UNDELETE_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}/undelete?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${USERS_UNDELETE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${USERS_UNDELETE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

users_update() {


    userKeyMeta=( 
        'string'
        'Email or immutable ID of the user. If ID, it should match with id of user object'
    )


    if [[ -z "${USERS_UPDATE_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "USERS_UPDATE_userKey=${userKey}"

    fi

    

    USERS_UPDATE_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}?key=${CLIENTID}"


    curl -s \
        --request PUT \
        ${USERS_UPDATE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request PUT \\ 
        ${USERS_UPDATE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

users_watch() {



    USERS_WATCH_URL="https://www.googleapis.com/admin/directory/v1/users/watch?key=${CLIENTID}"

    optParams=( event orderBy projection sortOrder viewType )

    eventMeta=(
        'string'
        'Event on which subscription is intended'
        '["eventTypeUnspecified","add","delete","makeAdmin","undelete","update"]'
    )

    orderByMeta=(
        'string'
        'Column to use for sorting results'
        '["orderByUnspecified","email","familyName","givenName"]'
    )

    projectionMeta=(
        'string'
        'What subset of fields to fetch for this user.'
        '["projectionUnspecified","basic","custom","full"]'
    )

    sortOrderMeta=(
        'string'
        'Whether to return results in ascending or descending order.'
        '["sortOrderUnspecified","ASCENDING","DESCENDING"]'
    )

    viewTypeMeta=(
        'string'
        'Whether to fetch the ADMIN_VIEW or DOMAIN_PUBLIC view of the user.'
        '["admin_view","domain_public"]'
    )


    echo -en "# Would you like to define extra parameters? [y/n] \n${optParams}\n\n~> "
    read -r optParChoice
    clear


    if [[ ${optParChoice} =~ "y" ]] || [[ ${optParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#optParams[@]} ; i++ ))
        do

            select option in ${optParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            USERS_WATCH_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            USERS_WATCH_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam
                        
                        break
                    fi
                fi
            done
        done
    fi
    inpParams=( customFieldMask customer domain maxResults pageToken query showDeleted )

    customFieldMaskMeta=(
        'string'
        'Comma-separated list of schema names. All fields from these schemas are fetched. This should only be set when projection=custom.'
    )

    customerMeta=(
        'string'
        'Immutable ID of the G Suite account. In case of multi-domain, to fetch all users for a customer, fill this field instead of domain.'
    )

    domainMeta=(
        'string'
        'Name of the domain. Fill this field to get users from only this domain. To return all users in a multi-domain fill customer field instead."'
    )

    maxResultsMeta=(
        'integer'
        'Maximum number of results to return.'
    )

    pageTokenMeta=(
        'string'
        'Token to specify next page in the list'
    )

    queryMeta=(
        'string'
        'Query string search. Should be of the form "". Complete documentation is at https: //developers.google.com/admin-sdk/directory/v1/guides/search-users'
    )

    showDeletedMeta=(
        'string'
        'If set to true, retrieves the list of deleted users. (Default: false)'
    )


    echo -en "# Would you like to define input parameters? [y/n] \n${inpParams}\n\n~> "
    read -r inpParChoice
    clear


    if [[ ${inpParChoice} =~ "y" ]] || [[ ${inpParChoice} =~ "Y" ]]
    then
        for (( i = 1 ; i <= ${#inpParams[@]} ; i++ ))
        do

            select option in ${inpParams} none
            do
                if [[ -n ${option} ]]
                then
                    if [[ ${option} =~ "none" ]]
                    then
                        clear
                        break 2
                    else
                        clear

                        local optParam=PARAM_${option}
                        if ! [[ -z "${(P)${optParam}}" ]]
                        then 
                            checkParams ${option} "true"
                            USERS_WATCH_URL+="${tempUrlPar}"
                            unset tempUrlPar


                        else
                            getParams ${option} "true"
                            USERS_WATCH_URL+="${tempUrlPar}"
                            unset tempUrlPar

                        fi
                        unset optParam

                        break
                    fi
                fi
            done
        done
    fi

    curl -s \
        --request POST \
        ${USERS_WATCH_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${USERS_WATCH_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

verificationCodes_generate() {


    userKeyMeta=( 
        'string'
        'Email or immutable ID of the user'
    )


    if [[ -z "${VERIFICATIONCODES_GENERATE_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "VERIFICATIONCODES_GENERATE_userKey=${userKey}"

    fi

    

    VERIFICATIONCODES_GENERATE_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}/verificationCodes/generate?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${VERIFICATIONCODES_GENERATE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${VERIFICATIONCODES_GENERATE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

verificationCodes_invalidate() {


    userKeyMeta=( 
        'string'
        'Email or immutable ID of the user'
    )


    if [[ -z "${VERIFICATIONCODES_INVALIDATE_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "VERIFICATIONCODES_INVALIDATE_userKey=${userKey}"

    fi

    

    VERIFICATIONCODES_INVALIDATE_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}/verificationCodes/invalidate?key=${CLIENTID}"


    curl -s \
        --request POST \
        ${VERIFICATIONCODES_INVALIDATE_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request POST \\ 
        ${VERIFICATIONCODES_INVALIDATE_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --header "Content-Type: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

verificationCodes_list() {


    userKeyMeta=( 
        'string'
        'Identifies the user in the API request. The value can be the user'\''s primary email address, alias email address, or unique user ID.'
    )


    if [[ -z "${VERIFICATIONCODES_LIST_userKey}" ]]
    then
        if ! [[ -z "${PARAM_userKey}" ]]
        then 
            checkParams userKey "false"
            
        else
            getParams userKey
        fi
        declare -g "VERIFICATIONCODES_LIST_userKey=${userKey}"

    fi

    

    VERIFICATIONCODES_LIST_URL="https://www.googleapis.com/admin/directory/v1/users/${userKey}/verificationCodes?key=${CLIENTID}"


    curl -s \
        --request GET \
        ${VERIFICATIONCODES_LIST_URL} \
        --header "Authorization: Bearer ${ACCESSTOKEN}" \
        --header "Accept: application/json" \
        --compressed \
        | jq -c '.' \
        | read -r outputJson
        export outputJson

        #sentRequest=''

        echo -e "# Request issued:\n\n"
        echo -e "#########################\n"
        cat << EOIF

    curl -s \\ 
        --request GET \\ 
        ${VERIFICATIONCODES_LIST_URL} \\ 
EOIF
        cat << EOIF
        --header "Authorization: Bearer ${ACCESSTOKEN}" \\ 
EOIF
        cat << EOIF
        --header "Accept: application/json" \\ 
EOIF
        cat << EOIF
        --compressed
EOIF

        echo -e "\n\n"
        echo -e "#########################\n"


}

