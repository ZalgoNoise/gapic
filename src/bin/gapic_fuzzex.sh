#!/bin/zsh
#   Copyright 2020 ZalgoNoise
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


# Fuzzy Menu

gapicFuzzyMenu() {
    sed 's/ /\n/g' \
    | fzf \
    --preview \
        "{ cat \
          <(echo -e \"# Please choose an option, and press Enter #\") \
          <(echo -e \"# Tab: Query quick-replace #\n\n\") \
         } && [[ -f ${gapicSchemaDir}{}.json ]] \
           && { cat  <( jq -C  '.' ${gapicSchemaDir}{}.json ) } \
           || { cat <( jq -C '.' ${gapicLogDir}${gapicReqLog} ) }" \
    --bind "tab:replace-query" \
    --bind "ctrl-space:execute% cat ${1}  | jq --sort-keys -C .resources.{}.methods | less -R > /dev/tty 2>&1 %" \
    --bind "change:top"     --layout=reverse-list \
    --prompt="~ " \
    --pointer="~ " \
    --header="# gapic: API Composer #" \
    --color=dark \
    --black 

}

# Fuzzy History

gapicFuzzyHistory() { 
    jq -c '.[]' \
    | fzf \
    --preview "cat \
      <(echo -e \"# Ctrl-space: Expand preview (use '/' to search) #\")  \
      <(echo -e \"# Tab: query quick-replace #\") \
      <(echo -e \"# Search for a keyword and press Enter to replay request #\n\n\") \
      <(jq -C {} < ${1} ) \
      " \
    --bind "ctrl-space:execute% cat <(jq -C {1} < ${1}) | less -R > /dev/tty 2>&1 %" \
    --bind "tab:replace-query" \
    --layout=reverse-list \
    --prompt="~ " \
    --pointer="~ " \
    --header="# Fuzzy Request History Explorer #" \
    --color=dark \
    --black 
}

# Schema explorer / fuzzy finder

gapicFuzzySchema() {
    cat ${1} \
    | jq 'path(..) | map(tostring) | join(".")' \
    | sed "s/\"//g" \
    | sed "s/^/./" \
    | sed "s/\.\([[:digit:]]\+\)/[\1]/g" \
    | fzf  \
    --preview \
        "cat \
          <(echo -e \"# Ctrl-space: Expand preview (use '/' to search) #\")  \
          <(echo -e \"# Ctrl-k: preview keys #\") \
          <(echo -e \"# Tab: query quick-replace #\n\n\") \
          <(jq -C {1} < ${1})" \
    --bind "ctrl-s:execute% cat <(jq -c {1} < ${1}) | less -R > /dev/tty 2>&1 %" \
    --bind "ctrl-b:preview(cat <(jq -c {1} < ${1}) | base64 -d)" \
    --bind "ctrl-k:preview(cat <(jq -c {1} < ${1}) | jq '. | keys[]')" \
    --bind "tab:replace-query" \
    --bind "ctrl-space:execute% cat <(jq -C {1} < ${1}) | less -R > /dev/tty 2>&1 %" \
    --bind "change:top" \
    --layout=reverse-list \
    --prompt="~ " \
    --pointer="~ " \
    --header="# Fuzzy Object Explorer #" \
    --color=dark \
    --black \
    | xargs -ri jq -C {} <(cat ${1})
}

gapicFuzzyResources() {
    sed 's/ /\n/g' \
    | fzf \
    --preview \
        "cat \
          <(echo -e \"# Ctrl-space: Expand preview (use '/' to search) #\") \
          <(echo -e \"# Tab: query quick-replace #\n\n\") \
          <( cat ${1} | jq -C  \
            '.resources.{}.methods | keys[]')
        " \
    --bind "tab:replace-query" \
    --bind "ctrl-space:execute% cat ${1}  | jq --sort-keys -C .resources.{}.methods | less -R > /dev/tty 2>&1 %" \
    --bind "change:top" \
    --layout=reverse-list \
    --prompt="~ " \
    --pointer="~ " \
    --header="# ${schemaRef}: Resources #" \
    --color=dark \
    --black 
}

gapicFuzzyMethods() {
    sed 's/ /\n/g' \
    | sed "s/^[^.]*_//g" \
    | fzf \
    --preview \
        "cat \
          <(echo -e \"# Ctrl-space: Expand preview (use '/' to search) #\n\n\") \
          <( cat ${1} | jq -C  \
            .resources.${2}.methods.{})
        " \
    --bind "tab:replace-query" \
    --bind "ctrl-space:execute% cat ${1}  | jq --sort-keys -C .resources.${2}.methods.{} | less -R > /dev/tty 2>&1 %" \
    --bind "change:top" \
    --layout=reverse-list \
    --prompt="~ " \
    --pointer="~ " \
    --header="# ${2}: Methods #" \
    --color=dark \
    --black 
}

fuzzExSimpleParameters() {
    sed 's/ /\n/g' \
    | fzf \
    --bind "tab:replace-query" \
    --bind "change:top" \
    --layout=reverse-list \
    --bind "ctrl-r:execute% source ${gapicParamWiz} && rmParams ${tempPar} {} ${credPath}/${fileRef} %+preview(cat <(echo -e \# Removed {}))" \
    --preview "cat <(echo -e \"# Ctrl-r: Remove entry #\n\n\") <( cat ${schemaFile} | jq --sort-keys -C  .resources.${1}.methods.${2}.parameters.${3})" \
    --prompt="~ " \
    --pointer="~ " \
    --header="# ${1}.${2}: Saved ${3} Params #" \
    --color=dark \
    --black 
}

fuzzExOptParameters() {
    sed 's/ /\n/g' \
    | fzf \
    --bind "tab:replace-query" \
    --bind "change:top" \
    --layout=reverse-list \
    --preview "cat ${schemaFile} | jq --sort-keys -C  .resources.${1}.methods.${2}.parameters.${3}" \
    --prompt="~ " \
    --pointer="~ " \
    --header="# ${1}.${2}: ${3} Param #" \
    --color=dark \
    --black 
}

fuzzExAllParameters() {
    sed 's/ /\n/g' \
    | fzf \
    --bind "tab:replace-query" \
    --bind "change:top" \
    --layout=reverse-list \
    --preview "cat ${schemaFile} | jq --sort-keys -C  \".resources.${1}.methods.${2}.parameters\"" \
    --prompt="~ " \
    --pointer="~ " \
    --header="# ${1}.${2}: Available Params #" \
    --color=dark \
    --black 
}

fuzzExPromptParameters() {
    sed 's/ /\n/g' \
    | fzf \
    --bind "tab:replace-query" \
    --bind "change:top" \
    --layout=reverse-list \
    --preview "cat <(echo ${2} | sed 's/ /\n/g')" \
    --prompt="~ " \
    --pointer="~ " \
    --header="# ${1} #" \
    --color=dark \
    --black 
}

fuzzExPostParametersPrompt() {
    fzf \
    --bind "tab:replace-query" \
    --bind "change:top" \
    --layout=reverse-list \
    --preview "cat ${schemaFile} | jq --sort-keys -C  ${1}" \
    --prompt="~ " \
    --pointer="~ " \
    --header="# ${2} #" \
    --color=dark \
    --black 
}


fuzzExPostParametersPreview() {
    fzf \
    --bind "tab:replace-query" \
    --bind "change:top" \
    --layout=reverse-list \
    --preview "cat ${schemaFile} | jq --sort-keys -C  .schemas.${1}.properties.{}"  \
    --prompt="~ " \
    --pointer="~ " \
    --header="# ${2} #" \
    --color=dark \
    --black
}

fuzzExSavedCreds() {
    fzf \
    --bind "tab:replace-query" \
    --bind "change:top" \
    --layout=reverse-list \
    --preview "cat <( cat ${2}/{} | jq -C )" \
    --prompt="~ " \
    --pointer="~ " \
    --header="# ${1} #" \
    --color=dark \
    --black \
    | xargs -ri cat ${2}/{} \
    | jq -c '.' 
}

fuzzExInputCreds(){
    echo \
    | fzf \
    --print-query \
    --prompt="~ " \
    --pointer="~ " \
    --header="# ${1} #" \
    --color=dark \
    --black
}

fuzzExSavedScopes() {
    jq ".scopeUrl" \
    | fzf \
    --bind "tab:replace-query" \
    --bind "change:top" \
    --layout=reverse-list \
    --preview "cat ${2} | jq -C \".authScopes[] | select(.scopeUrl == \"{}\")\" " \
    --prompt="~ " \
    --pointer="~ " \
    --header="# ${1} #" \
    --color=dark \
    --black \
    | xargs -ri echo {} \
    | sed 's/"//g'
}

fuzzExCreateScopes() {
    jq ".resources.${2}.methods.${3}.scopes[]" \
    | fzf \
    --bind "tab:replace-query" \
    --bind "change:top" \
    --layout=reverse-list \
    --preview "cat <( cat ${4} | jq -C \".resources.${2}.methods.${3}\")" \
    --prompt="~ " \
    --pointer="~ " \
    --header="# ${1} #" \
    --color=dark \
    --black \
    | xargs -ri echo {} \
    | sed 's/"//g'
}

