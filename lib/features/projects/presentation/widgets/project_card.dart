import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../src/widgets/tag_chip.dart';
import '../../domain/entities/project_summary.dart';

/// A project card (PROJECT_SPEC §7.3).
///
/// Shows cover, title, domain, tagline, and up to three tech chips. The domain
/// label matters: it is what stops the card reading as a generic placeholder
/// and tells a recruiter what the project actually was.
class ProjectCard extends StatefulWidget {
  final ProjectSummary project;
  final VoidCallback onTap;

  const ProjectCard({super.key, required this.project, required this.onTap});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final ProjectSummary project = widget.project;
    final bool isMobile = context.isMobile;

    return MouseRegion(
      // Flutter only delivers these for a real pointer, so a touchscreen laptop
      // does not get stuck hover states (SPEC risk R-11).
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: CustomContainer(
        onTap: widget.onTap,
        color: colors.surface2,
        borderColor: _isHovered ? colors.accent : colors.borderSubtle,
        borderRadius: BorderValues.medium.borderAll,
        padding: PaddingValues.zero,
        hoverLift: true,
        semanticLabel:
            '${project.title.of(context)}. ${project.tagline.of(context)}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildCover(context),
            Padding(
              padding: PaddingValues.p20.pAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomText(
                    project.domain.of(context).toUpperCase(),
                    fontSize: FontSize.labelDesktop,
                    fontWeight: FontWeightManager.semiBold,
                    color: colors.accent,
                    letterSpacing: 1.1,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                  AppSize.s8.spaceH,
                  CustomText.display(
                    project.title.of(context),
                    fontSize: isMobile
                        ? FontSize.h2Mobile
                        : FontSize.h2Desktop,
                    height: LineHeights.heading,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                  AppSize.s8.spaceH,
                  CustomText(
                    project.tagline.of(context),
                    fontSize: FontSize.captionDesktop,
                    color: colors.textSecondary,
                    textAlign: TextAlign.start,
                    maxLines: 2,
                  ),
                  if (project.primaryTech.isNotEmpty) ...<Widget>[
                    AppSize.s16.spaceH,
                    Wrap(
                      spacing: AppSize.s6,
                      runSpacing: AppSize.s6,
                      children: <Widget>[
                        for (final String tech in project.primaryTech.take(3))
                          TagChip(tech, dense: true),
                      ],
                    ),
                  ],
                  AppSize.s20.spaceH,
                  // The affordance that turns a card into an invitation.
                  // Always present, brightening and nudging on hover rather
                  // than appearing from nothing — a control that materialises
                  // only on hover is undiscoverable on touch
                  // (design system §Cards).
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CustomText(
                        StringsManager.viewCaseStudy.tr(context),
                        fontSize: FontSize.labelDesktop,
                        fontWeight: FontWeightManager.semiBold,
                        color: _isHovered
                            ? colors.accent
                            : colors.textTertiary,
                      ),
                      AppSize.s6.spaceW,
                      AnimatedSlide(
                        offset: _isHovered && !context.reduceMotion
                            ? const Offset(0.3, 0)
                            : Offset.zero,
                        duration: DurationValues.dm150.milliseconds,
                        curve: AppCurves.state,
                        child: Icon(
                          context.isRtl
                              ? IconsManager.back
                              : IconsManager.forward,
                          size: AppSize.s14,
                          color: _isHovered
                              ? colors.accent
                              : colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderValues.medium.borderTop.asBorderRadius,
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: AnimatedScale(
          scale: _isHovered && !context.reduceMotion ? 1.03 : 1.0,
          duration: DurationValues.dm250.milliseconds,
          curve: AppCurves.state,
          child: CustomImage(
            path: widget.project.coverPath,
            fit: BoxFit.cover,
            monogram: widget.project.title.of(context),
            semanticLabel: widget.project.title.of(context),
          ),
        ),
      ),
    );
  }
}
