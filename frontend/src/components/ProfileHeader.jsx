import { useMemo, useState } from "react";
// import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
//import { toast } from "react-hot-toast";
import { Camera, Clock, MapPin, UserCheck, UserPlus, X } from "lucide-react";
//import { axiosInstance } from "../lib/axios";

const ProfileHeader = ({ userData, onSave, isOwnProfile }) => {
    const [isEditing, setIsEditing] = useState(false);
    const [editedData, setEditedData] = useState({});

    // Commenting out react-query related functionality
    // const queryClient = useQueryClient();
    // const { data: authUser } = useQuery({ queryKey: ["authUser"] });

    // Commented out as it’s not being used in the static display
    // const { data: connectionStatus, refetch: refetchConnectionStatus } = useQuery({
    // 	queryKey: ["connectionStatus", userData._id],
    // 	queryFn: () => axiosInstance.get(`/connections/status/${userData._id}`),
    // 	enabled: !isOwnProfile,
    // });

    // const isConnected = userData.connections.some((connection) => connection === authUser._id);

    // Commenting out mutation hooks as they’re unused for static display
    // const { mutate: sendConnectionRequest } = useMutation({ ... });
    // const { mutate: acceptRequest } = useMutation({ ... });
    // const { mutate: rejectRequest } = useMutation({ ... });
    // const { mutate: removeConnection } = useMutation({ ... });

    // For demonstration, hard-coding the connection status here
    const getConnectionStatus = useMemo(() => "connected", []); // Changed to static display

    const renderConnectionButton = () => {
        const baseClass = "text-white py-2 px-4 rounded-full transition duration-300 flex items-center justify-center";
        switch (getConnectionStatus) {
            case "connected":
                return (
                    <div className='flex gap-2 justify-center'>
                        <div className={`${baseClass} bg-green-500 hover:bg-green-600`}>
                            <UserCheck size={20} className='mr-2' />
                            Connected
                        </div>
                        {/* Removed the functionality of removeConnection as this is static */}
                        <button className={`${baseClass} bg-red-500 hover:bg-red-600 text-sm`}>
                            <X size={20} className='mr-2' />
                            Remove Connection
                        </button>
                    </div>
                );

            case "pending":
                return (
                    <button className={`${baseClass} bg-yellow-500 hover:bg-yellow-600`}>
                        <Clock size={20} className='mr-2' />
                        Pending
                    </button>
                );

            case "received":
                return (
                    <div className='flex gap-2 justify-center'>
                        <button className={`${baseClass} bg-green-500 hover:bg-green-600`}>
                            Accept
                        </button>
                        <button className={`${baseClass} bg-red-500 hover:bg-red-600`}>
                            Reject
                        </button>
                    </div>
                );
            default:
                return (
                    <button className='bg-primary hover:bg-primary-dark text-white py-2 px-4 rounded-full transition duration-300 flex items-center justify-center'>
                        <UserPlus size={20} className='mr-2' />
                        Connect
                    </button>
                );
        }
    };

    // Handle image and save logic is retained to allow profile editing
    const handleImageChange = (event) => {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onloadend = () => {
                setEditedData((prev) => ({ ...prev, [event.target.name]: reader.result }));
            };
            reader.readAsDataURL(file);
        }
    };

    const handleSave = () => {
        onSave(editedData);
        setIsEditing(false);
    };

    return (
        <div className='bg-white shadow rounded-lg mb-6'>
            <div
                className='relative h-48 rounded-t-lg bg-cover bg-center'
                style={{
                    backgroundImage: `url('${editedData.bannerImg || userData.bannerImg || "/banner.png"}')`,
                }}
            >
                {isEditing && (
                    <label className='absolute top-2 right-2 bg-white p-2 rounded-full shadow cursor-pointer'>
                        <Camera size={20} />
                        <input
                            type='file'
                            className='hidden'
                            name='bannerImg'
                            onChange={handleImageChange}
                            accept='image/*'
                        />
                    </label>
                )}
            </div>

            <div className='p-4'>
                <div className='relative -mt-20 mb-4'>
                    <img
                        className='w-32 h-32 rounded-full mx-auto object-cover'
                        src={editedData.profilePicture || userData.profilePicture || "/avatar.png"}
                        alt={userData.name}
                    />

                    {isEditing && (
                        <label className='absolute bottom-0 right-1/2 transform translate-x-16 bg-white p-2 rounded-full shadow cursor-pointer'>
                            <Camera size={20} />
                            <input
                                type='file'
                                className='hidden'
                                name='profilePicture'
                                onChange={handleImageChange}
                                accept='image/*'
                            />
                        </label>
                    )}
                </div>

                <div className='text-center mb-4'>
                    {isEditing ? (
                        <input
                            type='text'
                            value={editedData.name ?? userData.name}
                            onChange={(e) => setEditedData({ ...editedData, name: e.target.value })}
                            className='text-2xl font-bold mb-2 text-center w-full'
                        />
                    ) : (
                        <h1 className='text-2xl font-bold mb-2'>{userData.name}</h1>
                    )}

                    {isEditing ? (
                        <input
                            type='text'
                            value={editedData.headline ?? userData.headline}
                            onChange={(e) => setEditedData({ ...editedData, headline: e.target.value })}
                            className='text-gray-600 text-center w-full'
                        />
                    ) : (
                        <p className='text-gray-600'>{userData.headline}</p>
                    )}

                    <div className='flex justify-center items-center mt-2'>
                        <MapPin size={16} className='text-gray-500 mr-1' />
                        {isEditing ? (
                            <input
                                type='text'
                                value={editedData.location ?? userData.location}
                                onChange={(e) => setEditedData({ ...editedData, location: e.target.value })}
                                className='text-gray-600 text-center'
                            />
                        ) : (
                            <span className='text-gray-600'>{userData.location}</span>
                        )}
                    </div>
                </div>

                {isOwnProfile ? (
                    isEditing ? (
                        <button
                            className='w-full bg-primary text-white py-2 px-4 rounded-full hover:bg-primary-dark transition duration-300'
                            onClick={handleSave}
                        >
                            Save Profile
                        </button>
                    ) : (
                        <button
                            onClick={() => setIsEditing(true)}
                            className='w-full bg-primary text-white py-2 px-4 rounded-full hover:bg-primary-dark transition duration-300'
                        >
                            Edit Profile
                        </button>
                    )
                ) : (
                    <div className='flex justify-center'>{renderConnectionButton()}</div>
                )}
            </div>
        </div>
    );
};

export default ProfileHeader;
