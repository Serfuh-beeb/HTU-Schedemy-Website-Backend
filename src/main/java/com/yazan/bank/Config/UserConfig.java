
package com.yazan.bank.Config;

import com.yazan.bank.model.*;
import com.yazan.bank.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.sql.Time;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;


@Configuration
public class UserConfig {
    @Bean
    CommandLineRunner commandLineRunner2(SchedulesRepository schedulesRepository,RoomRepository roomRepository, InstructorsRepository instructorsRepository, CoursesRepository coursesRepository, TimeSlotRepository timeSlotRepository) {
        return args -> {
            // Only seed data if the database is empty (prevents duplicate key errors on restart)
            if (instructorsRepository.count() > 0) {
                System.out.println("Database already seeded, skipping initialization.");
                return;
            }

            List<String> instructorNames = List.of(
                    "Dr. Adam Khalil",
                    "Dr. Lina Haddad",
                    "Dr. Omar Saleh",
                    "Dr. Noor Zaid",
                    "Eng. Rami Nasser",
                    "Eng. Sara Mansour",
                    "Eng. Ali Qasem",
                    "Eng. Huda Farah",
                    "Mr. Yazan Darwish",
                    "Ms. Tala Shuqair"
            );

            List<String> mappedJobTitles = List.of(
                    "Professor",
                    "Associate Professor",
                    "Assistant Professor",
                    "Assistant Professor",
                    "Lecturer",
                    "Lecturer",
                    "Instructor",
                    "Instructor",
                    "Assistant Instructor",
                    "Assistant Instructor"
            );

            List<String> instructorEmails = List.of(
                    "adam.khalil@htu.edu.jo",
                    "lina.haddad@htu.edu.jo",
                    "omar.saleh@htu.edu.jo",
                    "noor.zaid@htu.edu.jo",
                    "rami.nasser@htu.edu.jo",
                    "sara.mansour@htu.edu.jo",
                    "ali.qasem@htu.edu.jo",
                    "huda.farah@htu.edu.jo",
                    "yazan.darwish@htu.edu.jo",
                    "tala.shuqair@htu.edu.jo"
            );

            List<Department> departments = List.of(
                    Department.COMPUTER_SCIENCE,
                    Department.CYBER_SECURITY,
                    Department.ARTIFICIAL_INTELLIGENCE,
                    Department.COMPUTER_SCIENCE,
                    Department.CYBER_SECURITY,
                    Department.ARTIFICIAL_INTELLIGENCE,
                    Department.COMPUTER_SCIENCE,
                    Department.CYBER_SECURITY,
                    Department.ARTIFICIAL_INTELLIGENCE,
                    Department.COMPUTER_SCIENCE
            );


            System.out.println(instructorEmails.size());
            System.out.println(mappedJobTitles.size());
            System.out.println(departments.size());
            System.out.println(instructorNames.size());

            List<Instructors> instructorsList = new ArrayList<>();

            for (int i = 0; i < instructorNames.size(); i++) {
                Instructors instructor = new Instructors();
                instructor.setName(instructorNames.get(i));
                instructor.setJobTitle(mappedJobTitles.get(i));
                instructor.setEmail(instructorEmails.get(i));
                instructor.setDepartment(departments.get(i));
                instructorsList.add(instructor);
            }

            instructorsRepository.saveAll(instructorsList);

            List<String> courseNames = List.of(
                    "Programming", "Advanced Programming", "Data Structures & Algorithms", "Software Development Lifecycles",
                    "Website Design & Development", "Prototyping", "Planning a Computing Project", "ERP Systems",
                    "Systems Analysis & Design", "Operating Systems", "Application Development", "Games Engine & Scripting",
                    "Database Programing", "Systems Programing", "Internet of Things", "Cloud Computing", "E-Commerce",
                    "Special Topics in Computer Science", "Advanced Computer Architecture", "Networking", "Network Security",
                    "Security", "Cryptography", "Penetration Testing", "Computer Organization and Design",
                    "Special Topics in Cybersecurity 1", "Data Analytics", "Artificial Intelligence & Intelligent Systems",
                    "Principles of Data Science and Computing Systems", "Data Science Programming", "Database Design & Development",
                    "Big Data Analytics and Visualization", "Business Process Support", "Modeling and Simulation",
                    "Machine Learning", "Applied Analytical Models", "Data Mining"
            );

            List<Department> courseDepartments = List.of(
                    Department.CYBER_SECURITY, Department.CYBER_SECURITY, Department.CYBER_SECURITY, Department.CYBER_SECURITY,
                    Department.CYBER_SECURITY, Department.CYBER_SECURITY, Department.CYBER_SECURITY, Department.CYBER_SECURITY,
                    Department.CYBER_SECURITY, Department.CYBER_SECURITY, Department.CYBER_SECURITY, Department.CYBER_SECURITY,
                    Department.CYBER_SECURITY, Department.CYBER_SECURITY, Department.CYBER_SECURITY, Department.CYBER_SECURITY,
                    Department.CYBER_SECURITY, Department.CYBER_SECURITY, Department.CYBER_SECURITY, Department.CYBER_SECURITY,
                    Department.CYBER_SECURITY, Department.CYBER_SECURITY, Department.CYBER_SECURITY, Department.CYBER_SECURITY,
                    Department.CYBER_SECURITY, Department.CYBER_SECURITY, Department.ARTIFICIAL_INTELLIGENCE,
                    Department.ARTIFICIAL_INTELLIGENCE, Department.ARTIFICIAL_INTELLIGENCE, Department.ARTIFICIAL_INTELLIGENCE,
                    Department.ARTIFICIAL_INTELLIGENCE, Department.ARTIFICIAL_INTELLIGENCE, Department.ARTIFICIAL_INTELLIGENCE,
                    Department.ARTIFICIAL_INTELLIGENCE, Department.ARTIFICIAL_INTELLIGENCE, Department.ARTIFICIAL_INTELLIGENCE,
                    Department.ARTIFICIAL_INTELLIGENCE
            );

           List<Courses> coursesList = new ArrayList<>();
            int size = Math.min(courseDepartments.size(),Math.min(courseNames.size(),departments.size()));

            for (int i = 0; i < size; i++) {
                Courses courses = new Courses();
                courses.setName(courseNames.get(i));
                courses.setDepartment(departments.get(i));
                coursesList.add(courses);
            }
            coursesRepository.saveAll(coursesList);


            //Rooms
            List<String> roomnames = List.of(
                    "S-207","S-208","S-209","S-210","S-212","S-214","W07","W10","X1","X2",
                    "N-001","S-210", "S-212","Iman 7","Iman 8","N-001","iman12","X3"
            );

            List<Rooms> rooms = roomnames.stream().map(room -> new Rooms(room)).collect(Collectors.toList());
            roomRepository.saveAll(rooms);

            List<TimeSlots> slots = List.of(
                    // WEEKDAY Slots
                    new TimeSlots(Time.valueOf("08:30:00"), Time.valueOf("10:00:00"), DayType.WEEKDAY),
                    new TimeSlots(Time.valueOf("10:00:00"), Time.valueOf("11:30:00"), DayType.WEEKDAY),
                    new TimeSlots(Time.valueOf("11:30:00"), Time.valueOf("13:00:00"), DayType.WEEKDAY),
                    new TimeSlots(Time.valueOf("13:00:00"), Time.valueOf("14:30:00"), DayType.WEEKDAY),
                    new TimeSlots(Time.valueOf("14:30:00"), Time.valueOf("16:00:00"), DayType.WEEKDAY),
                    new TimeSlots(Time.valueOf("16:00:00"), Time.valueOf("17:30:00"), DayType.WEEKDAY),

                    // WEEKEND Slots
                    new TimeSlots(Time.valueOf("08:30:00"), Time.valueOf("11:30:00"), DayType.WEEKEND),
                    new TimeSlots(Time.valueOf("11:30:00"), Time.valueOf("14:30:00"), DayType.WEEKEND),
                    new TimeSlots(Time.valueOf("14:30:00"), Time.valueOf("17:30:00"), DayType.WEEKEND)
            );

            timeSlotRepository.saveAll(slots);

            for(TimeSlots slot: slots){
                for(Rooms room: rooms){
                    schedulesRepository.save(new Schedules(
                            slot,room
                    ));
                }
            }
        };
    }
}


