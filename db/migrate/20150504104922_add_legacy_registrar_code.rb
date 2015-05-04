class AddLegacyRegistrarCode < ActiveRecord::Migration
  def change
    legacy_codes = [
        [1, "EEDIRECT"],
        [2, "ALMIC"],
        [3, "ELION"],
        [4, "SPINTEK"],
        [5, "LINXTELECOM"],
        [6, "ZONE"],
        [7, "WEBNEST"],
        [8, "NETPOINT"],
        [9, "EESTIDOMEENID"],
        [10, "CEMTY"],
        [11, "NORTHSIDE"],
        [12, "EENET"],
        [13, "ELKDATA"],
        [14, "ELISA"],
        [15, "OKIA"],
        [16, "NAMEISP"],
        [17, "ASCIO"],
        [18, "TPT"],
        [22, "TPT2"],
        [23, "INFONET"],
        [24, "INTERFRAME"],
        [25, "DOMAININFO"],
        [26, "DELETEDDOMAINS"],
        [27, "WAVECOM"],
        [28, "CACTUSHOSTING"],
        [29, "IPMIRROR"],
        [30, "ALFANET"],
        [31, "RIKS"],
        [32, "AKS"],
        [33, "VIRTUAAL"],
        [34, "MIKARE_BALTIC"],
        [35, "COMPIC"],
        [36, "NETIM"],
        [37, "TRENET"],
        [38, "INSTRA"],
        [39, "123DOMAIN.EU"],
        [40, "EDICY"],
        [41, "MAJANDUSTARKVARA"],
        [44, "SAFENAMES"],
        [45, "INFOWEB"],
        [46, "EURODNS"],
        [47, "INNTER.NET"],
        [48, "RADICENTER"],
        [49, "DBWEB"],
        [50, "NAMESHIELD"],
        [51, "CEMTY_OU"],
        [52, "INFOBIT"]
    ]

    legacy_codes.each do |lc|
      legacy_id = lc.first
      legacy_code = lc.second
      registrar = Registrar.find_by(legacy_id: legacy_id)
      next if registrar.blank?
      old_code = registrar.code
      registrar.update_column(:code, legacy_code)
      puts "Registrar code updated: #{registrar.id}; #{registrar.name}; old: #{old_code}; new: #{registrar.reload.code}"
    end
  end
end
