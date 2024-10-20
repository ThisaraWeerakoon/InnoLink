import { useParams } from "react-router-dom";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { axiosInstance } from "../lib/axios";

import ProfileHeader from "../components/ProfileHeader";
import AboutSection from "../components/AboutSection";
import ExperienceSection from "../components/ExperienceSection";
import EducationSection from "../components/EducationSection";
import SkillsSection from "../components/SkillsSection";
import toast from "react-hot-toast";
import { useEffect } from "react";

//implement connection api and about section/ education etc. 
const ProfilePage = () => {
	const { username } = useParams();
	const queryClient = useQueryClient();
	
	const { data: authUser, isLoading } = useQuery({
		queryKey: ["authUser"],
	});
	console.log("authUser", authUser);
	const token= localStorage.getItem('jwt');
	const { data: userProfile, isLoading: isUserProfileLoading } = useQuery({
		queryKey: ["userProfile", username],
		queryFn: () => axiosInstance.get(`/users/getbyid/${username}?jwt=${token}`),
		
	});

	const { mutate: updateProfile } = useMutation({
		mutationFn: async (updatedData) => {
			await axiosInstance.put(`/users/update/${authUser.id}?jwt=${token}`, updatedData);
		},
		onSuccess: () => {
			toast.success("Profile updated successfully");
			queryClient.invalidateQueries(["userProfile", username]);
			console.log("userData on invalidation",userData);
		},
	});

	if (isLoading || isUserProfileLoading) return null;

	const isOwnProfile = (authUser.id === userProfile.data.id);
	const userData = userProfile.data;

	console.log('userData',userData);
	const handleSave = (updatedData) => {
		updateProfile(updatedData);
	};

	return (
		<div className='max-w-4xl mx-auto p-4'>
			<ProfileHeader userData={userData} isOwnProfile={isOwnProfile} onSave={handleSave} />
			<AboutSection userData={userData} isOwnProfile={isOwnProfile} onSave={handleSave} />
			<ExperienceSection userData={userData} isOwnProfile={isOwnProfile} onSave={handleSave} />
			<EducationSection userData={userData} isOwnProfile={isOwnProfile} onSave={handleSave} />
			<SkillsSection userData={userData} isOwnProfile={isOwnProfile} onSave={handleSave} />
		</div>
	);
};
export default ProfilePage;