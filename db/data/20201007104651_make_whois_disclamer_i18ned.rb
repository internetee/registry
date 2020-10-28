class MakeWhoisDisclamerI18ned < ActiveRecord::Migration[6.0]
  def up
    entry = SettingEntry.find_by(code: 'registry_whois_disclaimer')
    hash = { en: 'Search results may not be used for commercial, advertising, recompilation, repackaging, redistribution, reuse, obscuring or other similar activities.',
             et: 'Otsitulemusi ei tohi kasutada ärilistel, reklaami, ümber töötlemise, edasi levitamise, taaskasutuse, muutmise ega muul sarnasel eesmärgil.',
             ru: 'Результаты поиска не могут быть использованы в коммерческих целях, включая, но не ограничиваясь, рекламу, рекомпиляцию, изменение формата, перераспределение либо переиспользование.' }
    string = JSON.generate(hash)
    entry.format = 'hash'
    entry.value = string
    entry.save!
  end

  def down
    entry = SettingEntry.find_by(code: 'registry_whois_disclaimer')
    string = 'Search results may not be used for commercial, advertising, recompilation, \
              repackaging, redistribution, reuse, obscuring or other similar activities.'
    entry.format = 'string'
    entry.value = string
    entry.save!
  end
end
