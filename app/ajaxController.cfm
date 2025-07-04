ajax: {
    url: '/app/ajaxController.cfm',
    type: 'post',
    data: {
        contacts_table: '<cfoutput>#contacts_table#</cfoutput>',
        userid: '<cfoutput>#userid#</cfoutput>',
        bytag: '<cfoutput>#bytag#</cfoutput>',
        byimport: '<cfoutput>#byimport#</cfoutput>'
    }
},
