require 'test_helper'

module Certificates
  class CertificateGeneratorTest < ActiveSupport::TestCase
    setup do
      @generator = Certificates::CertificateGenerator.new(
        username: 'test_user',
        registrar_code: '1234',
        registrar_name: 'Test Registrar',
        interface: 'api'
      )
    end
  
    ## Тесты для публичных методов
  
    test "call генерирует CSR, ключ, сертификат и P12, если user_csr не передан" do
      generator = Certificates::CertificateGenerator.new(
        username: "test_user",
        registrar_code: "1234",
        registrar_name: "Test Registrar",
        interface: "api"
      )
    
      # Мокаем файловые операции, чтобы избежать ошибок
      mock_file = Minitest::Mock.new
      mock_file.expect :write, true, [String] # Для ключа, CSR, CRT, P12
      File.stub :open, ->(path, mode) { mock_file } do
        result = generator.call
    
        assert_instance_of String, result[:private_key], "Приватный ключ должен быть строкой"
        assert_instance_of String, result[:csr], "CSR должен быть строкой PEM"
        assert_instance_of String, result[:crt], "Сертификат должен быть строкой PEM"
        assert_instance_of String, result[:p12], "P12 должен быть строкой DER"
        assert_not_nil result[:expires_at], "Дата истечения должна быть установлена"
      end
    end
  
    test "call использует переданный user_csr и не создает ключ и P12" do
      # Создаем ключ и корректный CSR
      key = OpenSSL::PKey::RSA.new(2048)
      user_csr = OpenSSL::X509::Request.new
      user_csr.version = 0
      user_csr.subject = OpenSSL::X509::Name.new([["CN", "test_user"]])
      user_csr.public_key = key.public_key
      user_csr.sign(key, OpenSSL::Digest::SHA256.new)
      user_csr_pem = user_csr.to_pem
    
      generator = Certificates::CertificateGenerator.new(
        username: "test_user",
        registrar_code: "1234",
        registrar_name: "Test Registrar",
        user_csr: user_csr_pem,
        interface: "api"
      )
    
      result = generator.call
    
      assert_nil result[:private_key], "Приватный ключ не должен генерироваться"
      assert_nil result[:p12], "P12 не должен создаваться"
      assert_equal user_csr_pem, result[:csr], "CSR должен соответствовать переданному"
      assert_not_nil result[:crt], "Сертификат должен быть создан"
      assert_not_nil result[:expires_at], "Дата истечения должна быть установлена"
    end
  
    test "renew_certificate обновляет сертификат существующего пользователя" do
      # Создаем мок-объект существующего сертификата
      certificate = Certificate.new
      certificate.interface = 'api'
      
      generator = Certificates::CertificateGenerator.new(
        username: "test_user",
        registrar_code: "1234",
        registrar_name: "Test Registrar",
        certificate: certificate,
        interface: "api"
      )
      
      mock_file = Minitest::Mock.new
      mock_file.expect :write, true, [String] # Для файловых операций
      
      File.stub :open, ->(path, mode) { mock_file } do
        result = generator.renew_certificate
        
        assert_instance_of String, result[:crt], "Сертификат должен быть создан"
        assert_not_nil result[:expires_at], "Дата истечения должна быть установлена"
      end
    end
    
    test "renew_certificate вызывает исключение, если сертификат не передан" do
      generator = Certificates::CertificateGenerator.new(
        username: "test_user",
        registrar_code: "1234",
        registrar_name: "Test Registrar",
        interface: "api"
      )
      
      assert_raises(RuntimeError, "Certificate must be provided for renewal") do
        generator.renew_certificate
      end
    end
    
    test "renew_certificate с переданным CSR использует этот CSR" do
      # Создаем ключ и корректный CSR
      key = OpenSSL::PKey::RSA.new(2048)
      user_csr = OpenSSL::X509::Request.new
      user_csr.version = 0
      user_csr.subject = OpenSSL::X509::Name.new([["CN", "test_user"]])
      user_csr.public_key = key.public_key
      user_csr.sign(key, OpenSSL::Digest::SHA256.new)
      user_csr_pem = user_csr.to_pem
      
      # Создаем мок-объект существующего сертификата
      certificate = Certificate.new
      certificate.interface = 'api'
      
      generator = Certificates::CertificateGenerator.new(
        username: "test_user",
        registrar_code: "1234",
        registrar_name: "Test Registrar",
        certificate: certificate,
        user_csr: user_csr_pem,
        interface: "api"
      )
      
      result = generator.renew_certificate
      
      assert_nil result[:private_key], "Приватный ключ не должен генерироваться"
      assert_nil result[:p12], "P12 не должен создаваться"
      assert_equal user_csr_pem, result[:csr], "CSR должен соответствовать переданному"
      assert_not_nil result[:crt], "Сертификат должен быть создан"
    end
  
    ## Тесты для приватных методов
  
    test "generate_from_csr создает сертификат из CSR без ключа и P12" do
      # Создаем ключ и корректный CSR
      key = OpenSSL::PKey::RSA.new(2048)
      user_csr = OpenSSL::X509::Request.new
      user_csr.version = 0
      user_csr.subject = OpenSSL::X509::Name.new([["CN", "test_user"]])
      user_csr.public_key = key.public_key
      user_csr.sign(key, OpenSSL::Digest::SHA256.new)
      user_csr_pem = user_csr.to_pem
      
      generator = Certificates::CertificateGenerator.new(
        username: "test_user",
        registrar_code: "1234",
        registrar_name: "Test Registrar",
        user_csr: user_csr_pem,
        interface: "api"
      )
      
      result = generator.send(:generate_from_csr)
      
      assert_nil result[:private_key], "Приватный ключ не должен генерироваться"
      assert_nil result[:p12], "P12 не должен создаваться"
      assert_instance_of String, result[:csr], "CSR должен быть строкой PEM"
      assert_instance_of String, result[:crt], "Сертификат должен быть строкой PEM"
      assert_not_nil result[:expires_at], "Дата истечения должна быть установлена"
    end
    
    test "generate_new_certificate создает новый ключ, CSR, сертификат и P12" do
      mock_file = Minitest::Mock.new
      mock_file.expect :write, true, [String] # Для файловых операций
      
      File.stub :open, ->(path, mode) { mock_file } do
        result = @generator.send(:generate_new_certificate)
        
        assert_instance_of String, result[:private_key], "Приватный ключ должен быть строкой"
        assert_instance_of String, result[:csr], "CSR должен быть строкой PEM"
        assert_instance_of String, result[:crt], "Сертификат должен быть строкой PEM"
        assert_instance_of String, result[:p12], "P12 должен быть строкой DER"
        assert_not_nil result[:expires_at], "Дата истечения должна быть установлена"
      end
    end
  
    test "generate_csr_and_key создает CSR и ключ" do
      rsa_key = OpenSSL::PKey::RSA.new(4096)
      csr = OpenSSL::X509::Request.new
  
      OpenSSL::PKey::RSA.stub :new, rsa_key do
        OpenSSL::X509::Request.stub :new, csr do
          generated_csr, generated_key = @generator.send(:generate_csr_and_key)
  
          assert_equal csr, generated_csr, "CSR должен быть сгенерирован"
          assert_equal rsa_key, generated_key, "Ключ должен быть сгенерирован"
        end
      end
    end
  
    test "sign_certificate подписывает CSR с использованием CA" do
      key = OpenSSL::PKey::RSA.new(2048)
      csr = OpenSSL::X509::Request.new
      csr.version = 0
      csr.subject = OpenSSL::X509::Name.new([["CN", "test_user"]])
      csr.public_key = key.public_key
      csr.sign(key, OpenSSL::Digest::SHA256.new)
    
      generator = Certificates::CertificateGenerator.new(
        username: "test_user",
        registrar_code: "1234",
        registrar_name: "Test Registrar",
        interface: "api"
      )
    
      # Мокаем файловые операции для сохранения сертификата
      mock_file = Minitest::Mock.new
      mock_file.expect :write, true, [String]
      File.stub :open, ->(path, mode) { mock_file } do
        cert = generator.send(:sign_certificate, csr)
        assert_instance_of OpenSSL::X509::Certificate, cert, "Должен вернуться сертификат"
        assert_equal csr.subject.to_s, cert.subject.to_s, "Субъект должен совпадать"
      end
    end
  
    test "create_p12 создает PKCS12 с ключом и сертификатом" do
      key = OpenSSL::PKey::RSA.new(2048)
      cert = OpenSSL::X509::Certificate.new
      ca_cert = OpenSSL::X509::Certificate.new
      p12 = OpenSSL::PKCS12.new
  
      File.stub :read, ca_cert.to_pem do
        OpenSSL::X509::Certificate.stub :new, ca_cert do
          OpenSSL::PKCS12.stub :create, p12 do
            result = @generator.send(:create_p12, key, cert)
            assert_equal p12, result, "PKCS12 должен быть создан"
          end
        end
      end
    end
  
    test "ensure_directories_exist создает необходимые директории" do
      FileUtils.stub :mkdir_p, true do
        FileUtils.stub :chmod, true do
          assert_nothing_raised do
            @generator.send(:ensure_directories_exist)
          end
        end
      end
    end
  
    test "ensure_ca_exists проверяет наличие CA файлов и логирует предупреждение" do
      Rails.logger.expects(:warn).at_least_once
      
      # Мокаем отсутствие CA файлов
      File.stub :exist?, false do
        # Вызываем приватный метод
        @generator.send(:ensure_ca_exists)
      end
    end
  
    test "ensure_crl_exists создает CRL, если он отсутствует" do
      # Создаем мок-объект для файла
      mock_file = Minitest::Mock.new
      mock_file.expect :write, true, [String] # Ожидаем вызов write с аргументом типа String
    
      # Мокаем File.open, чтобы он возвращал наш мок-объект
      File.stub :open, ->(path, mode) { mock_file } do
        # Мокаем отсутствие CRL файла
        File.stub :exist?, false do
          # Мокаем существование CA сертификата и ключа, если они нужны для логики
          File.stub :exist?, true, [Certificates::CertificateGenerator::CA_CERT_PATHS['api']] do
            File.stub :exist?, true, [Certificates::CertificateGenerator::CA_KEY_PATHS['api']] do
              # Создаем экземпляр класса
              generator = Certificates::CertificateGenerator.new(
                username: "test_user",
                registrar_code: "1234",
                registrar_name: "Test Registrar",
                interface: "api"
              )
              # Вызываем приватный метод
              generator.send(:ensure_crl_exists)
            end
          end
        end
      end
    
      # Проверяем, что все ожидаемые вызовы были выполнены
      mock_file.verify
    end
  
    test "generate_unique_serial возвращает уникальный серийный номер" do
      serial1 = @generator.send(:generate_unique_serial)
      serial2 = @generator.send(:generate_unique_serial)
  
      assert_not_equal serial1, serial2, "Серийные номера должны быть уникальными"
      assert_instance_of Integer, serial1, "Серийный номер должен быть числом"
    end
  
    test "save_private_key сохраняет зашифрованный ключ" do
      key = OpenSSL::PKey::RSA.new(2048)
      encrypted_key = key.export(OpenSSL::Cipher.new('AES-256-CBC'), Certificates::CertificateGenerator::CA_PASSWORD)
  
      File.stub :write, true do
        FileUtils.stub :chmod, true do
          assert_nothing_raised do
            @generator.send(:save_private_key, encrypted_key)
          end
        end
      end
    end
  
    test "save_csr сохраняет CSR" do
      csr = OpenSSL::X509::Request.new
      File.stub :write, true do
        assert_nothing_raised do
          @generator.send(:save_csr, csr)
        end
      end
    end
  
    test "save_certificate сохраняет сертификат" do
      cert = OpenSSL::X509::Certificate.new
      File.stub :write, true do
        assert_nothing_raised do
          @generator.send(:save_certificate, cert)
        end
      end
    end
  end
end 