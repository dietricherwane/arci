# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Status.create([{ name: "Administrator" }, { name: "Writer" }])

Profile.create([{ name: "Administrateur", shortcut: "ADMIN" }, { name: "LV1", shortcut: "LV1" }, { name: "LV2", shortcut: "LV2" }, { name: "Chef de Département", shortcut: "CD" }, { name: "Chef du Département Banque de Données", shortcut: "CD-BD" }, { name: "Chef du Service d'Archivage de Données Physiques", shortcut: "CSADP-BD" }])

Department.create([{ name: "Banque de Données" }, { name: "Juridique" }, { name: "Moyens généraux" }])

Department.find_by_name("Banque de Données").qualifications.create([{ label: "Archiviste" }, { label: "Documentaliste" }])

Department.find_by_name("Juridique").qualifications.create([{ label: "Avocat" }, { label: "Chargé des contentieux" }])

Department.find_by_name("Moyens généraux").qualifications.create([{ label: "Logistique" }, { label: "Commercial" }])
