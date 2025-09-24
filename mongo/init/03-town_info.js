db = db.getSiblingDB('benchmark_db');

db.town_info.drop();

db.town_info.insertMany([
    {town_city: "London", region: "England", population: 9000000},
    {town_city: "Manchester", region: "England", population: 550000},
    {town_city: "Birmingham", region: "England", population: 1150000},
    {town_city: "Liverpool", region: "England", population: 500000},
    {town_city: "Leeds", region: "England", population: 800000},
    {town_city: "Sheffield", region: "England", population: 600000},
    {town_city: "Bristol", region: "England", population: 470000},
    {town_city: "Edinburgh", region: "Scotland", population: 500000},
    {town_city: "Glasgow", region: "Scotland", population: 635000},
    {town_city: "Cardiff", region: "Wales", population: 370000},
    {town_city: "Swansea", region: "Wales", population: 245000},
    {town_city: "Belfast", region: "Northern Ireland", population: 340000},
    {town_city: "Newcastle", region: "England", population: 300000},
    {town_city: "Nottingham", region: "England", population: 330000},
    {town_city: "Leicester", region: "England", population: 355000},
    {town_city: "Coventry", region: "England", population: 375000},
    {town_city: "Kingston upon Hull", region: "England", population: 260000},
    {town_city: "Bradford", region: "England", population: 360000},
    {town_city: "Stoke-on-Trent", region: "England", population: 255000},
    {town_city: "Wolverhampton", region: "England", population: 260000}
]);
