// import { useParams } from "react-router-dom";
// import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
// import { axiosInstance } from "../lib/axios";

import ProfileHeader from "../components/ProfileHeader";
import AboutSection from "../components/AboutSection";

// import toast from "react-hot-toast";

const ProfilePage = () => {
    // const { username } = useParams();
    // const queryClient = useQueryClient();
    //
    // const { data: authUser, isLoading } = useQuery({
    //     queryKey: ["authUser"],
    // });
    //
    // const { data: userProfile, isLoading: isUserProfileLoading } = useQuery({
    //     queryKey: ["userProfile", username],
    //     queryFn: () => axiosInstance.get(`/users/${username}`),
    // });
    //
    // const { mutate: updateProfile } = useMutation({
    //     mutationFn: async (updatedData) => {
    //         await axiosInstance.put("/users/profile", updatedData);
    //     },
    //     onSuccess: () => {
    //         toast.success("Profile updated successfully");
    //         queryClient.invalidateQueries(["userProfile", username]);
    //     },
    // });
    //
    // if (isLoading || isUserProfileLoading) return null;

    // Static user data to simulate an authenticated user and their profile
    const authUser = {
        username: "sampleUser",
        name: "Sample User",
        location: "Sample City",
        bio: "This is a sample bio.",
        // Add any other static fields you need
    };

    const isOwnProfile = true; // For static display, assume this is the user's own profile
    const userData = authUser; // Use static data

    // const handleSave = (updatedData) => {
    //     updateProfile(updatedData);
    // };

    return (
        <div className='max-w-4xl mx-auto p-4'>
            {/* Rendering the ProfileHeader and AboutSection with static userData, removed onSave instances*/}
            <ProfileHeader userData={userData} isOwnProfile={isOwnProfile} />
            <AboutSection userData={userData} isOwnProfile={isOwnProfile} />
        </div>
    );
};

export default ProfilePage;
