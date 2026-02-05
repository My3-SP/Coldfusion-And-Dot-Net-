<cfset inputList = trim(form.sortList)>

<cfif len(inputList) EQ 0>
    <cfset session.sortResult = "Enter a valid list of items!">
<cfelse>
    <cfset cleanedList = rereplace(inputList, "[,\s]+", ",", "all")>
    <cfset arr = listToArray(cleanedList)>

    <cfloop from="1" to="#arrayLen(arr)#" index="i">
        <cfloop from="1" to="#arrayLen(arr)-i#" index="j">
            <cfif arr[j] GT arr[j+1]> 
                <cfset temp = arr[j]>
                <cfset arr[j] = arr[j+1]>
                <cfset arr[j+1] = temp>
            </cfif>
        </cfloop>
    </cfloop>

    
    <cfset sortedList = arrayToList(arr)>
    <cfset session.sortResult = "<b>Input:</b> " & inputList & " <br> <b>Sorted:</b> " & sortedList>
</cfif>

<cflocation url="sortOutput.cfm" addtoken="no">
