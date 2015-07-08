package org.xtext.gradle.tasks;

import com.google.common.base.CharMatcher
import java.io.File
import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors
import org.gradle.api.DefaultTask
import org.gradle.api.tasks.TaskAction

class XtextEclipseSettings extends DefaultTask {

	@Accessors XtextSourceSetOutputs sourceSetOutputs
	@Accessors Set<Language> languages

	@TaskAction
	def writeSettings() {
		languages.forEach [ Language language |
			val prefs = new XtextEclipsePreferences(project, language.qualifiedName)
			prefs.load
			prefs.putBoolean("is_project_specific", true)
			sourceSetOutputs.getByName(language.name).forEach [ output |
				prefs.put(output.getKey("directory"), output.dir.projectRelativePath)
			]
			prefs.save
		]
	}

	def String getKey(LanguageSourceSetOutput output, String preferenceName) '''outlet.«output.name».«preferenceName»'''
	
	private def projectRelativePath(File file) {
		project.projectDir.toURI.relativize(file.toURI).path.trimTrailingSeparator
	}
	
	private def trimTrailingSeparator(String path) {
		CharMatcher.anyOf("/\\").trimTrailingFrom(path)
	}
}
