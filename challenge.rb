require 'json'

# Load data
companies = JSON.parse(File.read('companies.json'))
users = JSON.parse(File.read('users.json'))

def formatUser(user)
    output = "\t#{user['last_name']}, #{user['first_name']}, #{user['email']}"
    output << "\n\t\t\tPrevious Token Balance, #{user['tokens']}"
    output << "\n\t\t\tNew Token Balance #{user['newBalance']}"
    output
end


File.open('output.txt', 'w') do |file|
    for company in companies
        activeUsers = users
            .select { |u| u['active_status'] && u['company_id'] == company['id'] }
            .sort_by { |u| u['last_name'] }
        next if activeUsers.length == 0
        topupTotal = 0
        for user in activeUsers
            user['newBalance'] = user['tokens'] + company['top_up']
            topupTotal += company['top_up']
        end

        if company['email_status']
            usersEmailed = activeUsers.select {|u| u['email_status']}
            usersNotEmailed = activeUsers.select {|u| !u['email_status']}
        else
            usersEmailed = []
            usersNotEmailed = activeUsers
        end
        
        file.puts("\n\tCompany Id: #{company['id']}")
        file.puts("\tCompany Name: #{company['name']}")
        file.puts("\tUsers Emailed:")
        for userEmailed in usersEmailed
            file.puts("\t#{formatUser(userEmailed)}")
        end
        file.puts("\tUsers Not Emailed:")
        for userNotEmailed in usersNotEmailed
            file.puts("\t#{formatUser(userNotEmailed)}")
        end
        
        file.puts("\t\tTotal amount of top ups for #{company['name']}: #{topupTotal}")
        
    end
end