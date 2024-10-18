import { useParams } from "react-router-dom";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { axiosInstance } from "../lib/axios";

import ProfileHeader from "../components/ProfileHeader";
import AboutSection from "../components/AboutSection";
import ExperienceSection from "../components/ExperienceSection";
import EducationSection from "../components/EducationSection";
import SkillsSection from "../components/SkillsSection";
import toast from "react-hot-toast";

const ProfilePage = () => {
	const queryClient = useQueryClient();

	const { data: authUser, isLoading } = useQuery({
		queryKey: ["authUser"],
	});
	const token = localStorage.getItem("jwt");  // No need to pass token in getItem()

	// Use the token in the query parameter and make the request to the given URL
	const { data: userProfile, isLoading: isUserProfileLoading } = useQuery({
	    queryKey: ["userProfile", authUser?.id],
	    queryFn: () => axiosInstance.get(`/users/getbyid/${authUser.id}?jwt=${token}`),
		enabled: !!authUser?.id,
	});

	//connect to users/update
	const { mutate: updateProfile } = useMutation({
		mutationFn: async (updatedData) => {
			await axiosInstance.put("/users/profile", updatedData);
		},
		onSuccess: () => {
			toast.success("Profile updated successfully");
			queryClient.invalidateQueries(["userProfile", authUser.id]);
		},
	});

	if (isLoading || isUserProfileLoading) return null;

	const isOwnProfile = authUser?.id === userProfile?.data?.id;
	const userData = isOwnProfile ? authUser : userProfile?.data;

	const handleSave = (updatedData) => {
		updateProfile(updatedData);
	};

	return (
		<div className='max-w-4xl mx-auto p-4'>
			{/* <ProfileHeader userData={userData} isOwnProfile={isOwnProfile} onSave={handleSave} /> */}
			<AboutSection userData={userData} isOwnProfile={isOwnProfile} onSave={handleSave} />
			<ExperienceSection userData={userData} isOwnProfile={isOwnProfile} onSave={handleSave} />
			<EducationSection userData={userData} isOwnProfile={isOwnProfile} onSave={handleSave} />
			<SkillsSection userData={userData} isOwnProfile={isOwnProfile} onSave={handleSave} />
		</div>
	);
};
export default ProfilePage;
