[1mdiff --git a/doc/schemas/contact-1.0.xsd b/doc/schemas/contact-1.0.xsd[m
[1mindex dc2b366..9fa665a 100644[m
[1m--- a/doc/schemas/contact-1.0.xsd[m
[1m+++ b/doc/schemas/contact-1.0.xsd[m
[36m@@ -12,6 +12,7 @@[m
    -->[m
     <import namespace="urn:ietf:params:xml:ns:eppcom-1.0" schemaLocation="doc/schemas/eppcom-1.0.xsd"/>[m
     <import namespace="urn:ietf:params:xml:ns:epp-1.0" schemaLocation="doc/schemas/epp-1.0.xsd"/>[m
[32m+[m[32m    <import namespace="urn:ietf:params:xml:ns:eis-1.0" schemaLocation="doc/schemas/eis-1.0.xsd"/>[m[41m[m
 [m
     <annotation>[m
       <documentation>[m
[36m@@ -94,7 +95,7 @@[m
    -->[m
     <complexType name="createType">[m
       <sequence>[m
[31m-        <element name="id" type="eppcom:clIDType"/>[m
[32m+[m[32m        <element name="id" type="eppcom:clIDType" minOccurs="0"/>[m[41m[m
         <element name="postalInfo" type="contact:postalInfoType"[m
          maxOccurs="2"/>[m
         <element name="voice" type="contact:e164Type"[m
[36m@@ -103,10 +104,9 @@[m
          minOccurs="0"/>[m
         <element name="email" type="eppcom:minTokenType"/>[m
         <element name="ident" type="contact:identType"[m
[31m-          minOccurs="0"/> [m
[31m-        <element name="authInfo" type="contact:authInfoType"/>[m
[31m-        <element name="disclose" type="contact:discloseType"[m
[31m-         minOccurs="0"/>[m
[32m+[m[32m          minOccurs="0"/>[m[41m[m
[32m+[m[32m        <element name="authInfo" type="contact:authInfoType" minOccurs="0"/>[m[41m[m
[32m+[m[41m[m
       </sequence>[m
     </complexType>[m
 [m
[36m@@ -117,8 +117,7 @@[m
          minOccurs="0"/>[m
         <element name="addr" type="contact:addrType"/>[m
       </sequence>[m
[31m-      <attribute name="type" type="contact:postalInfoEnumType"[m
[31m-       use="required"/>[m
[32m+[m[32m      <attribute name="type" type="contact:postalInfoEnumType"/>[m[41m[m
     </complexType>[m
 [m
     <simpleType name="postalInfoEnumType">[m
[36m@@ -148,21 +147,6 @@[m
       </choice>[m
     </complexType>[m
 [m
[31m-    <complexType name="discloseType">[m
[31m-      <sequence>[m
[31m-        <element name="name" type="contact:intLocType"[m
[31m-         minOccurs="0" maxOccurs="2"/>[m
[31m-        <element name="org" type="contact:intLocType"[m
[31m-         minOccurs="0" maxOccurs="2"/>[m
[31m-        <element name="addr" type="contact:intLocType"[m
[31m-         minOccurs="0" maxOccurs="2"/>[m
[31m-        <element name="voice" minOccurs="0"/>[m
[31m-        <element name="fax" minOccurs="0"/>[m
[31m-        <element name="email" minOccurs="0"/>[m
[31m-      </sequence>[m
[31m-      <attribute name="flag" type="boolean" use="required"/>[m
[31m-    </complexType>[m
[31m-[m
     <complexType name="intLocType">[m
       <attribute name="type" type="contact:postalInfoEnumType"[m
        use="required"/>[m
[36m@@ -240,8 +224,6 @@[m
          minOccurs="0"/>[m
         <element name="authInfo" type="contact:authInfoType"[m
          minOccurs="0"/>[m
[31m-        <element name="disclose" type="contact:discloseType"[m
[31m-         minOccurs="0"/>[m
       </sequence>[m
     </complexType>[m
 [m
[36m@@ -331,8 +313,6 @@[m
          minOccurs="0"/>[m
         <element name="authInfo" type="contact:authInfoType"[m
          minOccurs="0"/>[m
[31m-        <element name="disclose" type="contact:discloseType"[m
[31m-         minOccurs="0"/>[m
       </sequence>[m
     </complexType>[m
 [m
[1mdiff --git a/doc/schemas/eis-1.0.xsd b/doc/schemas/eis-1.0.xsd[m
[1mindex 390c455..98a73ca 100644[m
[1m--- a/doc/schemas/eis-1.0.xsd[m
[1m+++ b/doc/schemas/eis-1.0.xsd[m
[36m@@ -26,8 +26,8 @@[m
     <sequence>[m
       <element name="legalDocument" type="eis:legalDocType"[m
       minOccurs="0" maxOccurs="1"/>[m
[31m-<!--       <element name="ident" type="eis:identType"[m
[31m-      minOccurs="0" maxOccurs="1"/> -->[m
[32m+[m[32m      <element name="ident" type="eis:identType"[m
[32m+[m[32m      minOccurs="0" maxOccurs="1"/>[m
     </sequence>[m
   </complexType>[m
 [m
[36m@@ -55,10 +55,11 @@[m
     </restriction>[m
   </simpleType>[m
 [m
[31m-  <!-- <complexType name="identType">[m
[32m+[m[32m  <complexType name="identType">[m
     <simpleContent>[m
       <extension base="normalizedString">[m
         <attribute name="type" type="eis:identEnumType" use="required"/>[m
[32m+[m[32m        <attribute name="cc" type="eis:ccType" use="required"/>[m
       </extension>[m
     </simpleContent>[m
   </complexType>[m
[36m@@ -70,5 +71,12 @@[m
       <enumeration value="birthday"/>[m
       <enumeration value="passport"/>[m
     </restriction>[m
[31m-  </simpleType> -->[m
[32m+[m[32m  </simpleType>[m
[32m+[m
[32m+[m[32m  <simpleType name="ccType">[m
[32m+[m[32m    <restriction base="normalizedString">[m
[32m+[m[32m      <minLength value="2"/>[m
[32m+[m[32m      <maxLength value="2"/>[m
[32m+[m[32m    </restriction>[m
[32m+[m[32m  </simpleType>[m
 </schema>[m
[1mdiff --git a/spec/epp/contact_spec.rb b/spec/epp/contact_spec.rb[m
[1mindex 02540e1..c576808 100644[m
[1m--- a/spec/epp/contact_spec.rb[m
[1m+++ b/spec/epp/contact_spec.rb[m
[36m@@ -2,6 +2,7 @@[m [mrequire 'rails_helper'[m
 [m
 describe 'EPP Contact', epp: true do[m
   before :all do[m
[32m+[m[32m    @xsd = Nokogiri::XML::Schema(File.read('doc/schemas/contact-1.0.xsd'))[m
     @registrar1 = Fabricate(:registrar1)[m
     @registrar2 = Fabricate(:registrar2)[m
     @epp_xml    = EppXml::Contact.new(cl_trid: 'ABC-12345')[m
[36m@@ -15,7 +16,7 @@[m [mdescribe 'EPP Contact', epp: true do[m
 [m
     @extension = {[m
       legalDocument: {[m
[31m-        value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',[m
[32m+[m[32m        value: 'dGVzdCBmYWlsCg==',[m
         attrs: { type: 'pdf' }[m
       },[m
       ident: {[m
[36m@@ -31,8 +32,10 @@[m [mdescribe 'EPP Contact', epp: true do[m
         extension = @extension if extension.blank?[m
 [m
         defaults = {[m
[32m+[m[32m          id: nil,[m
           postalInfo: {[m
             name: { value: 'John Doe' },[m
[32m+[m[32m            org: nil,[m
             addr: {[m
               street: { value: '123 Example' },[m
               city: { value: 'Tallinn' },[m
[36m@@ -48,7 +51,7 @@[m [mdescribe 'EPP Contact', epp: true do[m
       end[m
 [m
       it 'fails if request xml is missing' do[m
[31m-        response = epp_plain_request(@epp_xml.create, :xml)[m
[32m+[m[32m        response = epp_plain_request(@epp_xml.create, validate_input: false)[m
         response[:results][0][:msg].should ==[m
           'Required parameter missing: create > create > postalInfo > name [name]'[m
         response[:results][1][:msg].should ==[m
[36m@@ -103,7 +106,7 @@[m [mdescribe 'EPP Contact', epp: true do[m
       it 'successfully saves ident type' do[m
         extension = {[m
           legalDocument: {[m
[31m-            value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',[m
[32m+[m[32m            value: 'dGVzdCBmYWlsCg==',[m
             attrs: { type: 'pdf' }[m
           },[m
           ident: {[m
[36m@@ -205,7 +208,7 @@[m [mdescribe 'EPP Contact', epp: true do[m
       end[m
 [m
       it 'should generate server id when id is empty' do[m
[31m-        response = create_request({ id: { value: '' } })[m
[32m+[m[32m        response = create_request({ id: nil })[m
 [m
         response[:msg].should == 'Command completed successfully'[m
         response[:result_code].should == '1000'[m
[36m@@ -381,7 +384,7 @@[m [mdescribe 'EPP Contact', epp: true do[m
       it 'should update ident' do[m
         extension = {[m
           legalDocument: {[m
[31m-            value: 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSL0Zp==',[m
[32m+[m[32m            value: 'dGVzdCBmYWlsCg==',[m
             attrs: { type: 'pdf' }[m
           },[m
           ident: {[m
