# default fabricator should be reusable
Fabricator(:certificate) do
  api_user
  common_name 'cn'
  md5 'md5hash'
  interface 'api'
  csr "-----BEGIN CERTIFICATE REQUEST-----\n" \
      "MIIE+DCCAuACAQAwgZ0xCzAJBgNVBAYTAkVFMREwDwYDVQQIDAhIYXJqdW1hYTEQ\n" \
      "MA4GA1UEBwwHVGFsbGlubjEbMBkGA1UECgwSRWVzdGkgSW50ZXJuZXRpIFNBMRIw\n" \
      "EAYDVQQLDAlSRUdJU1RSQVIxEjAQBgNVBAMMCXdlYmNsaWVudDEkMCIGCSqGSIb3\n" \
      "DQEJARYVd2ViY2xpZW50QGludGVybmV0LmVlMIICIjANBgkqhkiG9w0BAQEFAAOC\n" \
      "Ag8AMIICCgKCAgEAuXronFj8CxPWGkyUhXf+/WirkFGb8a/My2+7GvQWYE10Nq4C\n" \
      "u9wDgjU3AuLw8qzwEeE3Z5uxHXWfwnshXOF6aJNCQWUsrs0odCxw69iIwCNGKhyF\n" \
      "jljtx8uSH8RRSRc8BFIUkvUpmp8m7kZTlB4FDey+XaGy4p/rImiAiwfFMIJMjdE9\n" \
      "9gk0EGDbomgP6KC3Ss/iQfuOFCQWSqjFuvp3mygr193YplaPgeLM1ERIW1LVFGDK\n" \
      "jy6keZ3E/Vb4O4qUPDRgTMr2KWM3Auzh2hXCymHNWn3yRn5Q4KSjJbG/P7Kz5nfZ\n" \
      "kY3eVRBIBll+1Q0VV7g+1B48zzjZX2qiY3iL77MV1oL17KeOO3PAxsEtptdqNgUa\n" \
      "Fpp73dwPST1ZKvq8FSgDKcdTCziSeViGhXjJRpEMr8FoeKNO7nvd1maKN9HAOy75\n" \
      "eSxatj6LoQ+JFN7Ci3IbwKFI7BnIHbEr9eP7O7Qbhljz2GE9+GWUqr3zwUEgpFSI\n" \
      "crAnRHQI2ALakEMsryF416zg5yr/bJp8/IzgZLaKpBVLOL88sI6r+JRdM6QXvKYx\n" \
      "XhamV6bH6CrR8ZYN4okaZH6sAcy8eyBnEmc05h/KsDzTNadwadeZe73F+PltoEXH\n" \
      "XgtpTpQ8XarN1uLq99WD6gWilAx3LF/xetCO86+w/MkYBmfOrXge+WLUUW8CAwEA\n" \
      "AaAVMBMGCSqGSIb3DQEJBzEGDAR0ZXN0MA0GCSqGSIb3DQEBCwUAA4ICAQAkTlU3\n" \
      "RcI6UMRA7As2FJSph3QurPebQFoZhnhMD+hb6+hXip8MY77YxLwo/ihB9wghaZKL\n" \
      "uV0BxjdZgjDt9GhA8dtPgaCp5LvB6kQYvcEzRvitN2CpJhtz39rlF3gxuy+RtpNf\n" \
      "5KbC691FivoXur1qx9I7mc4snB3DTzLiJPIZ6nQzPYcSVpPCbns30N/i/sOdHO0o\n" \
      "9hP5wlhCdYrOxad993m+InpMDyDWhB1+TA9ZO7gYpg8S4kBX3Cz9OXe80Pe56ZdK\n" \
      "pcgjTXnUDjNSRRGamJib2lyZ/axMbb/etwyy3X+jBDuOQropkmgrPEFJHpgNlFah\n" \
      "BuW7KEASqbw5YxpTSc0nDk5uxBw3voL8fk9M1sX64tbzGAEBRZnrWGeb1mOLM/YI\n" \
      "K6ocAYSBhNmWUzpHTwL7qSeP9ztQUGzoGHyRjBdan+1U2G75Kpj+TjEm/X8wmtnq\n" \
      "3/qVhUYNEavcZbgR1gSE45+mS8NsD7Oq0Xdc0UKsVDbUcCGIkGG9+ERAbRznfi3W\n" \
      "qhChtUxySX8T3SmX5mviwlJ5OwQVjdUF1/2voPK0oFK7zV+wZqcuORzDKdqB8XV7\n" \
      "MDcQjza4EOB78OmcHDgQ7nMXuY7/UL4F+bRZosxPy43X2JId5d+/GpgV8sP9dzK8\n" \
      "UGJDNEZ2YsBbPuKZS+2eNZ8g3sjjFBeadvrQ1w==\n" \
      "-----END CERTIFICATE REQUEST-----"
end
