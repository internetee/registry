# Steps to Update company_status.rake

- [x] Modify the CSV output to include the contact type (role) information
- [x] Filter the output to include only Estonian organization type contacts
- [ ] Ensure only registrant contacts are included in the output
- [ ] Remove duplicate entries for the same organization
- [ ] Add a column to indicate if the contact is deleted due to an overdue annual statement
- [ ] Create a separate CSV file for invalid registrant contacts
- [ ] Update the existing CSV output to include only contacts that fail validation against the business registry and whitelist
- [ ] Add error handling and logging for better debugging
- [ ] Update the task description and comments to reflect the new functionality
- [ ] Add a new rake task or option to generate the separate registrant-only CSV file
- [ ] Implement validation against the business registry for Estonian organization contacts
- [ ] Implement validation against the whitelist for Estonian organization contacts
- [ ] Optimize the code for better performance, especially when dealing with large datasets
- [ ] Add unit tests for the new functionality
- [ ] Update the documentation to reflect the changes and new output format
