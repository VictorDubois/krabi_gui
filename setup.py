from setuptools import find_packages, setup
from glob import glob

package_name = 'krabi_gui'

setup(
    name=package_name,
    version='0.0.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
        ('share/' + package_name + '/qml',
            glob('krabi_gui/qml/*.qml')),
        ('share/' + package_name + '/qml/components',
            glob('krabi_gui/qml/components/*.qml')),
        ('share/' + package_name + '/res',
            glob('krabi_gui/res/*')),
    ],
    install_requires=["jinja2", "pyyaml", "typeguard", "numpy", 'setuptools', 'PySide6>=6.0'],
    zip_safe=True,
    maintainer='maximusk',
    maintainer_email='mehdibeniche@gmail.com',
    description='Krabi robot GUI',
    license='TODO: License declaration',
    extras_require={'test': ['pytest']},
    entry_points={
        'console_scripts': [
            'krabi_gui = krabi_gui.krabi_gui:main'
        ],
    },
)
